package WebGUI::HTMLForm;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use CGI::Util qw(rearrange);
use strict qw(vars refs);
use WebGUI::DateTime;
use WebGUI::Form;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::HTMLForm

=head1 DESCRIPTION

Package that makes HTML forms typed data and significantly reduces the code needed for properties pages in WebGUI.

=head1 SYNOPSIS

 use WebGUI::HTMLForm;
 $f = WebGUI::HTMLForm->new;

 $f->checkbox(
	-name=>"whichOne",
	-label=>"Is red your favorite?",
	-value=>"red"
	);
 $f->checkList(
	-name=>"dayOfWeek",
	-options=>\%days,
	-label=>"Which day?"
	);
 $f->combo(
	-name=>"fruit",
	-options=>\%fruit,
	-label=>"Choose a fruit or enter your own."
	);
 $f->contentType(
	-name=>"contentType"
	);
 $f->date(
	-name=>"endDate",
	-label=>"End Date",
	-value=>$endDate
	);
 $f->dateTime(
	-name=>"endDate",
	-label=>"End Date",
	-value=>$endDate
	);
 $f->email(
	-name=>"emailAddress",
	-label=>"Email Address"
	);
 $f->fieldType(
	-name=>"dataType",
	-label=>"Type of Field"
	);
 $f->file(
	-name=>"image",
	-label=>"Image to Upload"
	);
 $f->filterContent(
	-name=>"filterThisContent",
	-label=>"Filter This Content"
	);
 $f->float(
	-name=>"distance",
	-label=>"5.1"
	);
 $f->group(
	-name=>"groupToPost",
	-label=>"Who can post?"
	);
 $f->hidden(
	-name=>"wid",
	-value=>"55"
	);
 $f->HTMLArea(
	-name=>"description",
	-label=>"Description"
	);
 $f->integer(
	-name=>"size",
	-label=>"Size"
	);
 $f->interval(
	-name=>"timeToLive",
	-label=>"How long should this last?",
	-intervalValue=>12,
	-unitsValue=>"hours"
	);
 $f->password(
	-name=>"identifier",
	-label=>"Password"
	);
 $f->phone(
	-name=>"cellPhone",
	-label=>"Cell Phone"
	);
 $f->radio(
	-name=>"whichOne",
	-label=>"Is red your favorite?",
	-value=>"red"
	);
 $f->radioList(
	-name=>"dayOfWeek",
	-options=>\%days,
	-label=>"Which day?"
	);
 $f->raw(
	-value=>"text"
	);
 $f->readOnly(
	-value=>"34",
	-label=>"Page ID"
	);
 $f->selectList(
	-name=>"dayOfWeek",
	-options=>\%days,
	-label=>"Which day?"
	);
 $f->submit;
 $f->template(
	-name=>"templateId",
	-label=>"Page Template"
	);
 $f->text(
	-name=>"firstName", 
	-label=>"First Name"
	);
 $f->textarea(
	-name=>"emailMessage",
	-label=>"Email Message"
	);
 $f->timeField(
	-name=>"endDate",
	-label=>"End Date",
	-value=>$endDate
	);
 $f->url(
	-name=>"homepage",
	-label=>"Home Page"
	);
 $f->whatNext(
	-options=>\%options
	);
 $f->yesNo(
	-name=>"happy",
	-label=>"Are you happy?"
	);
 $f->zipcode(
	-name=>"workZip",
	-label=>"Office Zip Code"
	);

 $f->print;
 $f->printRowsOnly;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub _subtext {
	my $output;
        if ($_[0] ne "") {
                $output .= '<span class="formSubtext"> '.$_[0].'</span>';
        } 
	return $output;
}

#-------------------------------------------------------------------
sub _tableFormRow {
	unless ($_[0]->{_noTable}) {
        	return '<tr><td class="formDescription" valign="top">'.$_[1].'</td><td class="tableData">'.$_[2]."</td></tr>\n";
	} else {
		return $_[2];
	}
}

#-------------------------------------------------------------------
sub _uiLevelChecksOut {
	if ($_[0] <= $session{user}{uiLevel}) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------

=head2 checkbox ( name [ label, checked, subtext, value, extras, uiLevel ] )

Adds a checkbox row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item checked 

If you'd like this box to be defaultly checked, set this to "1".

=item subtext

Extra text to describe this form element or to provide special instructions.

=item value

The default value for this form element. Defaults to "1".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub checkbox {
	my ($output);
	my ($self, @p) = @_;
    	my ($name, $label, $checked, $subtext, $value, $extras, $uiLevel) = 
		rearrange([qw(name label checked subtext value extras uiLevel)], @p);
	if (_uiLevelChecksOut($uiLevel)) {
		$output = WebGUI::Form::checkbox({
			"name"=>$name,
			"value"=>$value,
			"checked"=>$checked,
			"extras"=>$extras
			});
		$output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
	} else {
		if ($checked) {
			$output = WebGUI::Form::hidden({
				"name"=>$name,
				"value"=>$value
				});
		}
	}
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 checkList ( name, options [ , label, value, vertical, extras, subtext, uiLevel ] )

Adds a checkbox list row to this form.

=over

=item name

The name field for this form element.

=item options

The list of options for this list. Should be passed as a hash reference.

=item label

The left column label for this form row.

=item value

The default value(s) for this form element. This should be passed as an array reference.

=item vertical

If set to "1" the radio button elements will be laid out horizontally. Defaults to "0".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub checkList {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $options, $label, $value, $vertical, $extras, $subtext, $uiLevel) =
                rearrange([qw(name options label value vertical extras subtext uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		$output = WebGUI::Form::checkList({
			"name"=>$name,
			"options"=>$options,
			"value"=>$value,
			"vertical"=>$vertical,
			"extras"=>$extras
			});
        	$output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
	} else {
		$output = WebGUI::Form::hiddenList({
			"name"=>$name,
			"options"=>$options,
			"value"=>$value
			});
	}
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 combo ( name, options, [ label, value, size, multiple, extras, subtext, uiLevel ] )

Adds a combination select list / text box row to this form. If the text box is filled out it will have a value stored in "name"_new where name is the first field passed into this method.

=over

=item name

The name field for this form element.

=item options

The list of options for this select list. Should be passed as a hash reference.

=item label

The left column label for this form row.

=item value

The default value(s) for this form element. This should be passed as an array reference.

=item size

The number of characters tall this form element should be. Defaults to "1".

=item multiple

A boolean value for whether this select list should allow multiple selections. Defaults to "0".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub combo {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $options, $label, $value, $size, $multiple, $extras, $subtext, $uiLevel) =
                rearrange([qw(name options label value size multiple extras subtext uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::combo({
                        "name"=>$name,
			"options"=>$options,
                        "value"=>$value,
                        "size"=>$size,
			"multiple"=>$multiple,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hiddenList({
			"name"=>$name,
                        "options"=>$options,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 contentType ( name, types [ label, value, extras, subtext, uiLevel ] )

Adds a content type select list field to this form.

=over

=item name

The name field for this form element.

=item types

An array reference of field types to be displayed. The valid types are "code", "mixed", "html", and "text". Defaults to all types.

=item label

The left column label for this form row. Defaults to "Content Type".

=item value

The default value for this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "3".

=back

=cut

sub contentType {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $types, $label, $value, $extras, $subtext, $uiLevel) =
                rearrange([qw(name types label value extras subtext uiLevel)], @p);
	$uiLevel = 3 if ($uiLevel eq "");
        if (_uiLevelChecksOut($uiLevel)) {
		$label = WebGUI::International::get(1007) unless ($label);
                $output = WebGUI::Form::fieldType({
                        "name"=>$name,
                        "types"=>$types,
                        "value"=>$value,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hiddenList({
                        "name"=>$name,
                        types=>$types,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 date (  [name , value, label, afterEdit, extras, uiLevel ] )

Adds a database link select list to the form.

=over

=item name

The name of this form element.

=item value

The default value for this form element.

=item label

The left column label for this form row. Defaults to "Database Link".

=item afterEdit

A URL that will be acted upon after editing a database link. Typically there is a link next to the select list that reads "Edit this database link" and this is the URL to go to after editing is complete.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "5".

=back

=cut

sub databaseLink {
        my ($output, $subtext);
        my ($self, @p) = @_;
        my ($name, $value, $label, $afterEdit, $extras, $uiLevel) = 
		rearrange([qw(name value label afterEdit extras uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		$label = $label || WebGUI::International::get(1075);
		if (WebGUI::Privilege::isInGroup(3)) {
			#disabled until we can resolve the "new" wobject problem
        		#if ($afterEdit) {
                	#	$subtext = '<a href="'.WebGUI::URL::page("op=editDatabaseLink&lid=".$value
			#		."&afterEdit="
                        #		.WebGUI::URL::escape($afterEdit)).'">'.WebGUI::International::get(0).'</a> / ';
        		#}
        		$subtext .= '<a href="'.WebGUI::URL::page("op=listDatabaseLinks").'">'
				.WebGUI::International::get(981).'</a>';
		}
        	$output = WebGUI::Form::databaseLink({
                	"name"=>$name,
                	"value"=>$value,
                	"extras"=>$extras
                	});
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}



#-------------------------------------------------------------------

=head2 date ( name [ label, value, extras, subtext, size, noDate, uiLevel ] )

Adds a date row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default date. Pass as an epoch value. Defaults to today.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item noDate

By default a date is placed in the "value" field. Set this to "1" to turn off the default date.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub date {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $extras, $subtext, $size, $noDate, $uiLevel) =
                rearrange([qw(name label value extras subtext size noDate uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::date({
                        "name"=>$name,
                        "value"=>$value,
                        "noDate"=>$noDate,
                        "size"=>$size,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>epochToSet($value)
                        });
        }
        $self->{_data} .= $output;
}



#-------------------------------------------------------------------

=head2 dateTime ( name [ label, value, subtext, uiLevel, dateExtras, timeExtras ] )

Adds a date time row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default date and time. Pass as an epoch value. Defaults to today and now.

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=item extras 

Extra parameters such as javascript or style sheet information that you wish to add to the form element.

=back

=cut

sub dateTime {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $subtext, $uiLevel, $extras) = 
		rearrange([qw(name label value subtext uiLevel extras)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::dateTime({
                        "name"=>$name,
                        "value"=>$value,
			"extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name."_date",
                        "value"=>epochToSet($value)
                        });
                $output .= WebGUI::Form::hidden({
                        "name"=>$name."_time",
                        "value"=>epochToHuman($value,"%j:%n:%s")
                        });
        }
        $self->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 email ( name [ label, value, maxlength, extras, subtext, size, uiLevel ] )

Adds an email address row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub email {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::email({
                        "name"=>$name,
                        "value"=>$value,
                        "maxlength"=>$maxlength,
                        "size"=>$size,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 fieldType ( name, types [ label, value, size, extras, subtext, uiLevel ] )

Adds a field type select list field to this form. This is primarily useful for building dynamic form builders.

=over

=item name

The name field for this form element.

=item types

An array reference of field types to be displayed. The field names are the names of the methods from this forms package. Note that not all field types are supported. Defaults to all types.

=item label

The left column label for this form row.

=item value

The default value for this form element.

=item size

The number of characters tall this form element should be. Defaults to "1".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub fieldType {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $types, $label, $value, $size, $multiple, $extras, $subtext, $uiLevel) =
                rearrange([qw(name types label value size multiple extras subtext uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::fieldType({
                        "name"=>$name,
                        "types"=>$types,
                        "value"=>$value,
                        "multiple"=>$multiple,
                        "size"=>$size,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hiddenList({
                        "name"=>$name,
                        types=>$types,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 file ( name [ label, subtext, extras, size, uiLevel ] )

Adds a file browse row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item subtext

Extra text to describe this form element or to provide special instructions.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub file {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $subtext, $extras, $size, $uiLevel) =
                rearrange([qw(name label subtext extras size uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::file({
                        "name"=>$name,
                        "size"=>$size,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 filterContent ( [ name, label, value, extras, subtext, uiLevel ] )

Adds a content filter select list to the form for use with the WebGUI::HTML::filter() function.

=over

=item name

The name field for this form element. Defaults to "filterContent".

=item label

The left column label for this form row. Defaults to "Filter Content" (internationalized).

=item value

The default value for this form element. 

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here
as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub filterContent {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $extras, $subtext, $uiLevel) =
                rearrange([qw(name label value extras subtext uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		$label = WebGUI::International::get(418) if ($label eq "");
                $output = WebGUI::Form::filterContent({
                        "name"=>$name,
                        "value"=>$value,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 float ( name [ label, value, maxlength, extras, subtext, size, uiLevel ] )

Adds an integer row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.  Defaults to 11.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub float {
	my ($output);
	my ($self, @p) = @_;
	my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel) =
		rearrange([qw(name label value maxlength extras subtext size uiLevel)], @p);
	if (_uiLevelChecksOut($uiLevel)) {
		$output = WebGUI::Form::float({
			"name"=>$name,
			"value"=>$value,
			"maxlength"=>$maxlength,
			"size"=>$size,
			"extras"=>$extras
			});
		$output .= _subtext($subtext);
		$output = $self->_tableFormRow($label,$output);
	} else {
		$output = WebGUI::Form::hidden({
			"name"=>$name,
			"value"=>$value
			});
	}
	$self->{_data} .= $output;
} 



#-------------------------------------------------------------------

=head2 group ( name [ label, value, size, multiple, extras, subtext, uiLevel, excludeGroups ] )

Adds a group pull-down to this form. A group pull down provides a select list that provides name value pairs for all the groups in the WebGUI system.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default value(s) for this form element. This should be passed as an array reference. Defaults to "7" (Everyone).

=item size

How many rows should be displayed at once?

=item multiple

Set to "1" if multiple groups should be selectable.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=item excludeGroups

An array reference containing a list of groups to exclude from the list.

=back

=cut

sub group {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $size, $multiple, $extras, $subtext, $uiLevel, $excludeGroups) =
                rearrange([qw(name label value size multiple extras subtext uiLevel excludeGroups)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		if (WebGUI::Privilege::isInGroup(3)) {
			$subtext = manageIcon("op=listGroups").$subtext;
		}
                $output = WebGUI::Form::group({
                        "name"=>$name,
                        "size"=>$size,
                        "value"=>$value,
                        "multiple"=>$multiple,
                        "extras"=>$extras,
			excludeGroups=>$excludeGroups
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
		my $hashRef = WebGUI::SQL->buildHashRef("select groupId,groupName from groups");
                $output = WebGUI::Form::hiddenList({
			"name"=>$name,
                        "options"=>$hashRef,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 hidden ( name [ value ] )

Adds a hidden row to this form.

=over

=item name

The name field for this form element.

=item value

The default value for this form element.

=back

=cut

sub hidden {
        my ($self, @p) = @_;
        my ($name, $value) = rearrange([qw(name value)], @p);
        $self->{_data} .= WebGUI::Form::hidden({
		"name"=>$name,
		"value"=>$value
		});
}

#-------------------------------------------------------------------

=head2 HTMLArea ( name [ label, value, subtext, extras, wrap, rows, columns, uiLevel, popupToggle ] )

Adds an HTML area row to this form. An HTML area is different than a standard text area in that it provides rich edit functionality and some special error trapping for HTML and other special characters.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default value for this form element.

=item subtext

Extra text to describe this form element or to provide special instructions.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item wrap

The method for wrapping text in the text area. Defaults to "virtual". There should be almost no reason to specify this.

=item rows

The number of characters tall this form element should be. There should be no reason for anyone to specify this.

=item columns

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=item popupToggle

Defaults to "0". If set to "1" the rich editor will be a pop-up editor. If set to "0" the rich editor will be inline.

NOTE: WebGUI uses a great variety of rich editors. Not all of them are capable of inline mode, so even if you leave this set to "0" the editor may be a pop-up anyway.

=back

=cut

sub HTMLArea {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $subtext, $extras, $wrap, $rows, $columns, $uiLevel, $popupToggle) =
                rearrange([qw(name label value subtext extras wrap rows columns uiLevel popupToggle)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::HTMLArea({
                        "name"=>$name,
                        "value"=>$value,
                        "wrap"=>$wrap,
                        "columns"=>$columns,
                        "rows"=>$rows,
                        "extras"=>$extras,
			"popupToggle"=>$popupToggle
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 integer ( name [ label, value, maxlength, extras, subtext, size, uiLevel ] )

Adds an integer row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.  Defaults to 11.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub integer {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::integer({
                        "name"=>$name,
                        "value"=>$value,
                        "maxlength"=>$maxlength,
                        "size"=>$size,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 interval ( name [ label, intervalValue, unitsValue, extras, subtext, uiLevel ] )

Adds a time interval row to this form.

=over

=item name

The the base name for this form element. This form element actually returns two values under different names. They are name_interval and name_units.

=item label

The left column label for this form row.

=item intervalValue

The default value for interval portion of this form element. Defaults to '1'.

=item unitsValue

The default value for units portion of this form element. Defaults to 'seconds'. Possible values are 'seconds', 'minutes', 'hours', 'days', 'weeks', 'months', and 'years'.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub interval {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $intervalValue, $unitsValue, $extras, $subtext, $uiLevel) =
                rearrange([qw(name label intervalValue unitsValue extras subtext uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::interval({
                        "name"=>$name,
                        "intervalValue"=>$intervalValue,
                        "unitsValue"=>$unitsValue,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name.'_interval',
                        "value"=>$intervalValue
                        });
                $output .= WebGUI::Form::hidden({
                        "name"=>$name.'_units',
                        "value"=>$unitsValue
                        });
        }
        $self->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 new ( [ noTable, action, method, extras, enctype, tableExtras ] )

Constructor.

=over

=item noTable

If this is set to "1" then no table elements will be wrapped around each form element. Defaults to "0".

=item action

The Action URL for the form information to be submitted to. This defaults to the current page.

=item method

The form's submission method. This defaults to "POST" and probably shouldn't be changed.

=item extras

If you want to add anything special to your form like javascript actions, or stylesheet information, you'd add it in here as follows:

 '"name"="myForm" onChange="myForm.submit()"'

=item enctype 

The ecapsulation type for this form. This defaults to "multipart/form-data" and should probably never be changed.

=item tableExtras

If you want to add anything special to the form's table like a name or stylesheet information, you'd add it in here as follows:

 '"name"="myForm" class="formTable"'

=back

=cut

sub new {
	my ($header, $footer);
        my ($self, @p) = @_;
        my ($noTable, $action, $method, $extras, $enctype, $tableExtras) =
                rearrange([qw(noTable action method extras enctype tableExtras)], @p);
	$noTable = $noTable || 0;
	$header = "\n\n".WebGUI::Form::formHeader({
		"action"=>$action,
		"extras"=>$extras,
		"method"=>$method,
		"enctype"=>$enctype
		});
	$header .= "\n<table ".$tableExtras.'>' unless ($noTable);
	$footer = "</table>\n" unless ($noTable);
	$footer .= "</form>\n\n";
        bless {_noTable => $noTable, _header => $header, _footer => $footer, _data => ''}, $self;
}

#-------------------------------------------------------------------

=head2 password ( name [ label, value, subtext, maxlength, extras, size, uiLevel ] )

Adds a password row to this form. 

=over

=item name 

The name field for this form element.

=item label 

The left column label for this form row.

=item value

The default value for this form element.

=item subtext

Extra text to describe this form element or to provide special instructions.

=item maxlength 

The maximum number of characters to allow in this form element.  Defaults to "35".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size 

The number of characters wide this form element should be. There should be no reason for anyone to specify this. Defaults to "30" unless overridden in the settings.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub password {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $subtext, $maxlength, $extras, $size, $uiLevel) =
                rearrange([qw(name label value subtext maxlength extras size uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::password({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "maxlength"=>$maxlength,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 phone ( name [ label, value, maxlength, extras, subtext, size, uiLevel ] )

Adds a text row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub phone {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::phone({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "maxlength"=>$maxlength,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 print ( )

Returns the HTML for this form object.

=cut

sub print {
        return $_[0]->{_header}.$_[0]->{_data}.$_[0]->{_footer};
}

#-------------------------------------------------------------------

=head2 printRowsOnly ( )

Returns the HTML for this form object except for the form header and footer.

=cut

sub printRowsOnly {
        return $_[0]->{_data};
}

#-------------------------------------------------------------------

=head2 radio ( name [ label, checked, value, subtext, extras, uiLevel ] )

Adds a radio button row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item checked

If you'd like this radio button to be defaultly checked, set this to "1".

=item value

The default value for this form element.

=item subtext

Extra text to describe this form element or to provide special instructions.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub radio {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $checked, $value, $subtext, $extras, $uiLevel) =
                rearrange([qw(name label checked value subtext extras uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::radio({
                        "name"=>$name,
                        "value"=>$value,
                        "checked"=>$checked,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
		if ($checked) {
                	$output = WebGUI::Form::hidden({
                        	"name"=>$name,
                        	"value"=>$value
                        	});
		}
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 radioList ( name, options, [ label, value, vertical, extras, subtext, uiLevel ] )

Adds a radio button list row to this form.

=over

=item name

The name field for this form element.

=item options

The list of options for this list. Should be passed as a hash reference.

=item label

The left column label for this form row.

=item value

The default value for this form element. Should be passed as a scalar.

=item vertical

If set to "1" the radio button elements will be laid out horizontally. Defaults to "0".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub radioList {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $options, $label, $value, $vertical, $extras, $subtext, $uiLevel) =
                rearrange([qw(name options label value vertical extras subtext uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::radioList({
                        "name"=>$name,
                        "options"=>$options,
                        "value"=>$value,
                        "vertical"=>$vertical,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hiddenList({
			"name"=>$name,
                        "options"=>$options,
                        "value"=>[$value]
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 raw ( value, uiLevel )

Adds raw data to the form. This is primarily useful with the printRowsOnly method and if you generate your own form elements.

=over

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub raw {
        my ($output);
        my ($self, @p) = @_;
        my ($value, $uiLevel) = rearrange([qw(value uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		$self->{_data} .= $value;
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 readOnly ( value [ label, subtext, uiLevel ] )

Adds a read only row to this form. This is mainly used for displaying not editable properties, but it can also be used to quickly insert custom form elements.

=over

=item value 

The read only value.

=item label

The left column label for this form row.

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub readOnly {
        my ($output);
        my ($self, @p) = @_;
        my ($value, $label, $subtext, $uiLevel) =
                rearrange([qw(value label subtext uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = $value;
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------
#Use of this method is depricated. Use selectList instead.
sub select {
	my $self = shift;
	return $self->selectList(@_);
}

#-------------------------------------------------------------------

=head2 selectList ( name, options, [ label, value, size, multiple, extras, subtext, uiLevel ] )

Adds a select list row to this form.

=over

=item name

The name field for this form element.

=item options 

The list of options for this select list. Should be passed as a hash reference.

=item label

The left column label for this form row.

=item value

The default value(s) for this form element. This should be passed as an array reference.

=item size 

The number of characters tall this form element should be. Defaults to "1".

=item multiple

A boolean value for whether this select list should allow multiple selections. Defaults to "0".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub selectList {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $options, $label, $value, $size, $multiple, $extras, $subtext, $uiLevel) =
                rearrange([qw(name options label value size multiple extras subtext uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::selectList({
                        "name"=>$name,
                        "options"=>$options,
                        "value"=>$value,
                        "multiple"=>$multiple,
                        "size"=>$size,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hiddenList({
			"name"=>$name,
                        "options"=>$options,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 submit ( value [ label, extras, subtext ] )

Adds a submit button row to this form.

=over

=item value

The button text for this submit button. Defaults to "save".

=item label

The left column label for this form row.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=back

=cut

sub submit {
        my ($output);
        my ($self, @p) = @_;
        my ($value, $label, $extras, $subtext) = rearrange([qw(value label extras subtext)], @p);
        $output = WebGUI::Form::submit({
                "value"=>$value,
                "extras"=>$extras
                });
        $output .= _subtext($subtext);
        $output = $self->_tableFormRow($label,$output);
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 template ( name [, value, label, namespace, afterEdit, extras, uiLevel ] )

Adds a template select list to the form.

=over

=item name

The name of this form element.

=item value

The default value for this form element.

=item label

The left column label for this form row.

=item namespace

The namespace (or type) of templates to show in this list. Defaults to "Page".

=item afterEdit

A URL that will be acted upon after editing a template. Typically there is a link next to the select list that reads "Edit this template" and this is the URL to go to after editing is complete.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub template {
        my ($output, $subtext);
        my ($self, @p) = @_;
        my ($name, $value, $label, $namespace, $afterEdit, $extras, $uiLevel) = 
		rearrange([qw(name value label namespace afterEdit extras uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		$label = $label || WebGUI::International::get(356);
		if (WebGUI::Privilege::isInGroup(8)) {
        		if ($afterEdit) {
                		$subtext = editIcon("op=editTemplate&tid=".$value."&namespace=".$namespace."&afterEdit=".WebGUI::URL::escape($afterEdit));
        		}
        		$subtext .= manageIcon("op=listTemplates&namespace=$namespace");
		}
        	$output = WebGUI::Form::template({
                	"name"=>$name,
                	"value"=>$value,
                	"namespace"=>$namespace,
                	"extras"=>$extras
                	});
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 text ( name [ label, value, maxlength, extras, subtext, size, uiLevel ] )

Adds a text row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub text {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::text({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "maxlength"=>$maxlength,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 textarea ( name [ label, value, subtext, extras, wrap, rows, columns, uiLevel ] )

Adds a text area row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default value for this form element.

=item subtext

Extra text to describe this form element or to provide special instructions.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item wrap

The method for wrapping text in the text area. Defaults to "virtual". There should be almost no reason to specify this.

=item rows 

The number of characters tall this form element should be. There should be no reason for anyone to specify this.

=item columns

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub textarea {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $subtext, $extras, $wrap, $rows, $columns, $uiLevel) =
                rearrange([qw(name label value subtext extras wrap rows columns uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::textarea({
                        "name"=>$name,
                        "value"=>$value,
                        "wrap"=>$wrap,
                        "columns"=>$columns,
                        "rows"=>$rows,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 timeField ( name [ label, value, extras, subtext, size, noDate, uiLevel ] )

Adds a date row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default time. Pass as a number of seconds. Defaults to 0.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub timeField {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $extras, $subtext, $size, $uiLevel) =
                rearrange([qw(name label value extras subtext size uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::time({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>secondsToTime($value)
                        });
        }
        $self->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 url ( name [ label, value, maxlength, extras, subtext, size, uiLevel ] )

Adds a URL row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.  Defaults to 2048.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub url {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::url({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "maxlength"=>$maxlength,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 whatNext ( options [, value, name, label, subtext, uiLevel, extras ] )

Adds a "What next?" select list to this form for use with chained action forms in WebGUI.

=over

=item options

A hash reference of the possible actions that could happen next.

=item value

The selected element in this list.

=item name

The name field for this form element. Defaults to "proceed".

=item label

The left column label for this form row.

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "1".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

=cut

sub whatNext {
        my ($output);
        my ($self, @p) = @_;
        my ($options, $value, $name, $label, $subtext, $uiLevel, $extras) =
                rearrange([qw(options value name label subtext uiLevel extras)], @p);
	$uiLevel |= 1;
	$label |= WebGUI::International::get(744);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::whatNext({
                        "name"=>$name,
			"options"=>$options,
                        "value"=>$value,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 yesNo ( name [ label, value, extras, subtext, uiLevel ] )

Adds a yes/no radio menu to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default value(s) for this form element. Valid values are "1" and "0". Defaults to "1".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub yesNo {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $extras, $subtext, $uiLevel) =
                rearrange([qw(name label value extras subtext uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::yesNo({
                        "name"=>$name,
                        "value"=>$value,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
        } else {
		$value = 0 unless ($value);
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 zipcode ( name [ label, value, maxlength, extras, subtext, size, uiLevel ] )

Adds a zip code row to this form.

=over

=item name

The name field for this form element.

=item label

The left column label for this form row.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item subtext

Extra text to describe this form element or to provide special instructions.

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=back

=cut

sub zipcode {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::zipcode({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "maxlength"=>$maxlength,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}




1;

