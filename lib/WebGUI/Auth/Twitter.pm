package WebGUI::Auth::Twitter;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Auth';
use Net::Twitter;

=head1 NAME

WebGUI::Auth::Twitter -- Twitter auth for WebGUI

=head1 DESCRIPTION

Allow WebGUI to authenticate to WebGUI

=head1 METHODS

These methods are available from this class:

=cut

#----------------------------------------------------------------------------

=head2 new ( ... )

Create a new object

=cut

sub new {
    my $self    = shift->SUPER::new(@_);
    return bless $self, __PACKAGE__; # Auth requires rebless
}

#----------------------------------------------------------------------------

=head2 createTwitterUser ( twitterUserId, username )

    my $user    = $self->createTwitterUser( $twitterUserId, $username );

Create a new Auth::Twitter user with the given twitter userId and screen name.

=cut

sub createTwitterUser {
    my ( $self, $twitterUserId, $twitterScreenName ) = @_;
    my $user    = WebGUI::User->create( $self->session );
    $user->username( $twitterScreenName );
    $self->saveParams( $user->userId, $self->authMethod, { 
        "twitterUserId" => $twitterUserId,
    } );
    return $user;
}

#----------------------------------------------------------------------------

=head2 editUserSettingsForm ( )

Return the form to edit the settings of this Auth module

=cut

sub editUserSettingsForm {
    my $self = shift;
    my $session = $self->session;
    my ( $setting ) = $session->quick(qw( setting ));

    my $f = WebGUI::HTMLForm->new( $session );

    $f->yesNo( 
        name        => 'twitterEnabled',
        value       => $setting->get( 'twitterEnabled' ),
        label       => 'Enabled?',
        hoverHelp   => 'Enabled Twitter-based login',
    );

    $f->text(
        name        => 'twitterConsumerKey',
        value       => $setting->get( 'twitterConsumerKey' ),
        label       => 'Twitter Consumer Key',
        hoverHelp   => 'The Consumer Key from your application settings',
        subtext     => 'Get a Twitter API key from http://example.com',
    );

    $f->text( 
        name        => 'twitterConsumerSecret',
        value       => $setting->get( 'twitterConsumerSecret' ),
        label       => 'Twitter Consumer Secret',
        hoverHelp   => 'The Consumer Secret from your application settings',
    );

    return $f->printRowsOnly;
}

#----------------------------------------------------------------------------

=head2 editUserSettingsFormSave ( )

Process the form for this Auth module's settings

=cut

sub editUserSettingsFormSave {
    my $self    = shift;
    my $session = $self->session;
    my ( $form, $setting ) = $session->quick(qw( form setting ));

    my @fields  = qw( twitterEnabled twitterConsumerKey twitterConsumerSecret );
    for my $field ( @fields ) {
        $setting->set( $field, $form->get( $field ) );
    }

    return;
}

#----------------------------------------------------------------------------

=head2 www_login ( )

Begin the login procedure

=cut

sub www_login {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $url, $scratch, $setting ) = $session->quick( qw( url scratch setting ) );

    my $nt = Net::Twitter->new(
        traits          => [qw/API::REST OAuth/],
        consumer_key    => $setting->get( 'twitterConsumerKey' ),       # Test: '3hvJpBr73pa4FycNrqw',
        consumer_secret => $setting->get( 'twitterConsumerSecret' ),    # Test: 'E4M5DJ66RAXiHgNCnJES96yTqglttsUes6OBcw9A',
    );

    my $url = $nt->get_authorization_url(
                    callback => $url->getSiteURL . $url->page('op=auth&authType=Twitter&method=callback'),
                );

    $scratch->set( 'AuthTwitterToken', $nt->request_token );
    $scratch->set( 'AuthTwitterTokenSecret', $nt->request_token_secret );

    $session->http->setRedirect($url);
    return "redirect";
}

#----------------------------------------------------------------------------

=head2 www_callback ( )

Callback from the Twitter authentication. Try to log the user in, creating a 
new user account if necessary. 

If the username is taken, allow the user to choose a new one.

=cut

sub www_callback {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $form, $scratch, $db, $setting ) = $session->quick(qw( form scratch db setting ));

    my $verifier = $form->get('oauth_verifier');

    my $nt = Net::Twitter->new(
        traits => [qw/API::REST OAuth/],
        consumer_key    => $setting->get( 'twitterConsumerKey' ),       # Test: '3hvJpBr73pa4FycNrqw',
        consumer_secret => $setting->get( 'twitterConsumerSecret' ),    # Test: 'E4M5DJ66RAXiHgNCnJES96yTqglttsUes6OBcw9A',
    );
    $nt->request_token( $scratch->get('AuthTwitterToken') );
    $nt->request_token_secret( $scratch->get('AuthTwitterTokenSecret') );

    my ($access_token, $access_token_secret, $twitterUserId, $twitterScreenName )
        = $nt->request_access_token(verifier => $verifier);

    ### Log the user in
    # Find their twitter user ID
    my $userId  = $db->quickScalar( 
        "SELECT userId FROM authentication WHERE authMethod = ? AND fieldName = ? AND fieldData = ?",
        [ "Twitter", "twitterUserId", $twitterUserId ],
    );

    # Returning user
    if ( $userId ) {
        my $user    = WebGUI::User->new( $session, $userId );
        $self->user( $user );
        return $self->login;
    }
    # Otherwise see if their screen name exists and create a user
    elsif ( !WebGUI::User->newByUsername( $session, $twitterScreenName ) ) {
        my $user = $self->createTwitterUser( $twitterUserId, $twitterScreenName );
        $self->user( $user );
        return $self->login;
    }

    # Otherwise ask them for a new username to use
    $scratch->set( "AuthTwitterUserId", $twitterUserId );
    my $output  = '<h1>Choose a Username</h1>'
                . sprintf( '<p>Your twitter screen name "%s" is already taken. Please choose a new username.</p>', $twitterScreenName )
                . '<form><input type="hidden" name="op" value="auth" />'
                . '<input type="hidden" name="authType" value="Twitter" />'
                . '<input type="hidden" name="method" value="setUsername" />'
                . '<input type="text" name="newUsername" value="" />'
                . '<input type="submit" />'
                . '</form>'
                ;
    return $output;
}

#----------------------------------------------------------------------------

=head2 www_setUsername ( )

Set the username for a twitter user. Only used as part of the initial twitter
registration.

=cut

sub www_setUsername {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $form, $scratch, $db ) = $session->quick(qw( form scratch db ));

    my $username    = $form->get('newUsername');
    if ( !WebGUI::User->newByUsername( $session, $username ) ) {
        my $twitterUserId = $scratch->get( "AuthTwitterUserId" );
        my $user = $self->createTwitterUser( $twitterUserId, $username );
        $self->user( $user );
        return $self->login;
    }

    # Username is again taken! Noooooo!
    my $output  = '<h1>Choose a Username</h1>'
                . sprintf( '<p>The username "%s" is already taken. Please choose a new username.</p>', $username )
                . '<form><input type="hidden" name="op" value="auth" />'
                . '<input type="hidden" name="authType" value="Twitter" />'
                . '<input type="hidden" name="method" value="setUsername" />'
                . '<input type="text" name="newUsername" value="" />'
                . '<input type="submit" />'
                . '</form>'
                ;
    return $output;
}

1;
