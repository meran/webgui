package WebGUI::Operation;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::ErrorHandler;

=head1 NAME

Package WebGUI::Operation

=head1 DESCRIPTION

This package is provides dynamic loading capabilities for the WebGUI operations.

B<NOTE:>After adding a new operation, the operation / package name must be added to WebGUI::Operation::getOperations.

=head1 SYNOPSIS

 use WebGUI::Operation;
 $html = WebGUI::Operation::execute("switchAdminOn");
 $hashRef = WebGUI::Operation::getOperations();

=head1 METHODS

These functions are available from this package:

=cut

#-------------------------------------------------------------------

=head2 execute ( name )

Loads the corresponding module for operation <name> and executes the operation.
Returns html in most cases.

=head3 name 

The name of the operation to execute.

=cut

sub execute {
	my $op = shift;
	my ($output, $cmd);
	my $operation = getOperations();
	if ($operation->{$op}) {
		# Load the module
		$cmd = 'use '.$operation->{$op};
		eval ($cmd);
		WebGUI::ErrorHandler::fatalError("Couldn't compile operation: ".$operation->{$op}.". Root cause: ".$@) if ($@);
		# Call the method
		$cmd = $operation->{$op} . '::www_'.$op;
		$output = eval($cmd);
		WebGUI::ErrorHandler::fatalError("Couldn't execute operation : ".$cmd.". Root cause: ".$@) if ($@);
	} else {
                        WebGUI::ErrorHandler::security("execute an invalid operation: ".$op);
	}
	return $output;
}

#-------------------------------------------------------------------

=head2 getOperations ( )

Returns a hash reference containing operation and package names.

=cut

sub getOperations {
	return {
	  'adminConsole' => 'WebGUI::Operation::Admin',
          'switchOffAdmin' => 'WebGUI::Operation::Admin',
          'switchOnAdmin' => 'WebGUI::Operation::Admin',
          'auth' => 'WebGUI::Operation::Auth',
          'displayLogin' => 'WebGUI::Operation::Auth',
          'login' => 'WebGUI::Operation::Auth',
          'displayAccount' => 'WebGUI::Operation::Auth',
          'createAccount' => 'WebGUI::Operation::Auth',
          'deactivateAccount' => 'WebGUI::Operation::Auth',
          'logout' => 'WebGUI::Operation::Auth',
          'recoverPassword' => 'WebGUI::Operation::Auth',
          'init' => 'WebGUI::Operation::Auth',
          'copyDatabaseLink' => 'WebGUI::Operation::DatabaseLink',
          'deleteDatabaseLink' => 'WebGUI::Operation::DatabaseLink',
          'deleteDatabaseLinkConfirm' => 'WebGUI::Operation::DatabaseLink',
          'editDatabaseLink' => 'WebGUI::Operation::DatabaseLink',
          'editDatabaseLinkSave' => 'WebGUI::Operation::DatabaseLink',
          'listDatabaseLinks' => 'WebGUI::Operation::DatabaseLink',
          'formAssetTree' => 'WebGUI::Operation::FormHelpers',
          'richEditPageTree' => 'WebGUI::Operation::FormHelpers',
          'richEditImageTree' => 'WebGUI::Operation::FormHelpers',
          'richEditViewThumbnail' => 'WebGUI::Operation::FormHelpers',
          'manageUsersInGroup' => 'WebGUI::Operation::Group',
          'deleteGroup' => 'WebGUI::Operation::Group',
          'deleteGroupConfirm' => 'WebGUI::Operation::Group',
          'editGroup' => 'WebGUI::Operation::Group',
          'editGroupSave' => 'WebGUI::Operation::Group',
          'listGroups' => 'WebGUI::Operation::Group',
          'emailGroup' => 'WebGUI::Operation::Group',
          'emailGroupSend' => 'WebGUI::Operation::Group',
          'manageGroupsInGroup' => 'WebGUI::Operation::Group',
          'addGroupsToGroupSave' => 'WebGUI::Operation::Group',
          'deleteGroupGrouping' => 'WebGUI::Operation::Group',
          'autoAddToGroup' => 'WebGUI::Operation::Group',
          'autoDeleteFromGroup' => 'WebGUI::Operation::Group',
          'listGroupsSecondary' => 'WebGUI::Operation::Group',
          'manageUsersInGroupSecondary' => 'WebGUI::Operation::Group',
          'addUsersToGroupSave' => 'WebGUI::Operation::Group',
          'addUsersToGroupSecondarySave' => 'WebGUI::Operation::Group',
          'deleteGroupingSecondary' => 'WebGUI::Operation::Group',
          'viewHelp' => 'WebGUI::Operation::Help',
          'viewHelpIndex' => 'WebGUI::Operation::Help',
          'viewMessageLog' => 'WebGUI::Operation::MessageLog',
          'viewMessageLogMessage' => 'WebGUI::Operation::MessageLog',
          'editProfile' => 'WebGUI::Operation::Profile',
          'editProfileSave' => 'WebGUI::Operation::Profile',
          'viewProfile' => 'WebGUI::Operation::Profile',
          'deleteProfileCategoryConfirm' => 'WebGUI::Operation::ProfileSettings',
          'deleteProfileFieldConfirm' => 'WebGUI::Operation::ProfileSettings',
          'editProfileCategorySave' => 'WebGUI::Operation::ProfileSettings',
          'editProfileFieldSave' => 'WebGUI::Operation::ProfileSettings',
          'deleteProfileCategory' => 'WebGUI::Operation::ProfileSettings',
          'deleteProfileField' => 'WebGUI::Operation::ProfileSettings',
          'editProfileCategory' => 'WebGUI::Operation::ProfileSettings',
          'editProfileField' => 'WebGUI::Operation::ProfileSettings',
          'moveProfileCategoryDown' => 'WebGUI::Operation::ProfileSettings',
          'moveProfileCategoryUp' => 'WebGUI::Operation::ProfileSettings',
          'moveProfileFieldDown' => 'WebGUI::Operation::ProfileSettings',
          'moveProfileFieldUp' => 'WebGUI::Operation::ProfileSettings',
          'editProfileSettings' => 'WebGUI::Operation::ProfileSettings',
          'deleteReplacement' => 'WebGUI::Operation::Replacements',
          'editReplacement' => 'WebGUI::Operation::Replacements',
          'editReplacementSave' => 'WebGUI::Operation::Replacements',
          'listReplacements' => 'WebGUI::Operation::Replacements',
          'setScratch' => 'WebGUI::Operation::Scratch',
          'deleteScratch' => 'WebGUI::Operation::Scratch',
          'saveSettings' => 'WebGUI::Operation::Settings',
          'editSettings' => 'WebGUI::Operation::Settings',
          'viewStatistics' => 'WebGUI::Operation::Statistics',
          'killSession' => 'WebGUI::Operation::ActiveSessions',
          'viewLoginHistory' => 'WebGUI::Operation::LoginHistory',
          'viewActiveSessions' => 'WebGUI::Operation::ActiveSessions',
          'makePrintable' => 'WebGUI::Operation::Style',
          'setPersonalStyle' => 'WebGUI::Operation::Style',
          'unsetPersonalStyle' => 'WebGUI::Operation::Style',
          'viewTheme' => 'WebGUI::Operation::Theme',
          'deleteThemeComponent' => 'WebGUI::Operation::Theme',
          'deleteThemeComponentConfirm' => 'WebGUI::Operation::Theme',
          'importTheme' => 'WebGUI::Operation::Theme',
          'importThemeValidate' => 'WebGUI::Operation::Theme',
          'importThemeSave' => 'WebGUI::Operation::Theme',
          'exportTheme' => 'WebGUI::Operation::Theme',
          'addThemeComponent' => 'WebGUI::Operation::Theme',
          'addThemeComponentSave' => 'WebGUI::Operation::Theme',
          'deleteTheme' => 'WebGUI::Operation::Theme',
          'deleteThemeConfirm' => 'WebGUI::Operation::Theme',
          'editTheme' => 'WebGUI::Operation::Theme',
          'editThemeSave' => 'WebGUI::Operation::Theme',
          'listThemes' => 'WebGUI::Operation::Theme',
          'editUserKarma' => 'WebGUI::Operation::User',
          'editUserKarmaSave' => 'WebGUI::Operation::User',
          'deleteGrouping' => 'WebGUI::Operation::Group',
          'editGrouping' => 'WebGUI::Operation::Group',
          'editGroupingSave' => 'WebGUI::Operation::Group',
          'becomeUser' => 'WebGUI::Operation::User',
          'deleteUser' => 'WebGUI::Operation::User',
          'deleteUserConfirm' => 'WebGUI::Operation::User',
          'editUser' => 'WebGUI::Operation::User',
          'editUserSave' => 'WebGUI::Operation::User',
          'listUsers' => 'WebGUI::Operation::User',
          'theWg' => 'WebGUI::Operation::WebGUI',
          'genesis' => 'WebGUI::Operation::WebGUI',
	  'deleteSubscription' => 'WebGUI::Operation::Subscription',
	  'editSubscription' => 'WebGUI::Operation::Subscription',
	  'editSubscriptionSave' => 'WebGUI::Operation::Subscription',
	  'listSubscriptions' => 'WebGUI::Operation::Subscription',
	  'purchaseSubscription' => 'WebGUI::Operation::Subscription',
	  'createSubscriptionCodeBatch' => 'WebGUI::Operation::Subscription',
	  'createSubscriptionCodeBatchSave' => 'WebGUI::Operation::Subscription',
	  'deleteSubscriptionCodeBatch' => 'WebGUI::Operation::Subscription',
	  'listSubscriptionCodeBatches' => 'WebGUI::Operation::Subscription',
	  'redeemSubscriptionCode' => 'WebGUI::Operation::Subscription',
	  'listSubscriptionCodes' => 'WebGUI::Operation::Subscription',
	  'deleteSubscriptionCodes' => 'WebGUI::Operation::Subscription',
	  'checkout' => 'WebGUI::Operation::Commerce',
	  'checkoutConfirm' => 'WebGUI::Operation::Commerce',
	  'checkoutSubmit' => 'WebGUI::Operation::Commerce',
	  'editCommerceSettings' => 'WebGUI::Operation::Commerce',
	  'editCommerceSettingsSave' => 'WebGUI::Operation::Commerce',
	  'listPendingTransactions' => 'WebGUI::Operation::Commerce',
	  'cancelTransaction' => 'WebGUI::Operation::Commerce',
	  'completePendingTransaction' => 'WebGUI::Operation::Commerce',
	  'selectPaymentGateway' => 'WebGUI::Operation::Commerce',
	  'viewPurchaseHistory' => 'WebGUI::Operation::TransactionLog',
	  'cancelRecurringTransaction' => 'WebGUI::Operation::TransactionLog',
        };
}

1;
