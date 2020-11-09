#!/usr/bin/perl -w


# Globals

my $in_pre_document = 1;
my %pre_document_keywords = map{$_=>1}('title', 'author', 'date');
# contains \documentclass; \usepackage; title definitions etc
my @pre_document = ('
\documentclass{beamer}
\usepackage{amsmath}
\usepackage{graphicx}
\usepackage{hyperref}
\setbeamertemplate{footline}[page number]
');

my @title = ();
my %title_information = ();

# it will contain the generated latex document
my @document = ('\begin{document}');

my $in_frame = 0;

# keep the type of list (itemize or enumerate) and the depth
my @list_type = ();
my @list_level = ();


# Helpers

# Add a \n to each text line
sub add_line_return() {
    my @text;
    for $_(@_) {
	push @text, "$_\n";
    }
    return @text;
}

# Go through all the open lists of itemize and nicely terminate them
sub terminate_lists() {
    while (@list_type) {
	my $type = pop @list_type;
	push @document, '\end{'.$type.'}';
    }
    @list_level = ();
    @list_type = ();
}


# Main

while(<>) {
    chomp();
    s/\s*$//; # remove spaces

    # parsing the information needed for the pre document (title, author, etc)
    if ($in_pre_document == 1) {
	s/%.*$//; # remove comments

	if (/^(\S+):\s*(.+?)\s*$/) {
	    if (exists $pre_document_keywords{$1}) {
		$title_information{$1} = 1;
		push @title, "\\".lc($1).'{'.$2.'}';
	    }
	} elsif (/^(===|---)/) {
	    # document started
	    $in_pre_document = 0; # not in the preparation part anymore

	    # if a title is given use it to create a title page
	    if (exists $title_information{title}) {
		push @document, '\frame{\titlepage}';
	    }
	} else {
	    # some problem
	    # print $_ . "\n";
	}
    }

    # parsing the information for the document
    if ($in_pre_document == 0) {
	# __text__ will be rendered in italic
	s/__(.*?)__/\\textit{$1}/g; 

	# find url and replace by \url{.....}
	s/\b((https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~\\_|!:,.;]*[-A-Z0-9+&@#\/%=~\\_|])/\\url{$1}/gi;

	if (/^===(.*?)\s*===$/) {
	    # New section.

	    # if there are any running list of items, terminate them as 
	    # we are starting a new section
	    &terminate_lists();

	    if ($in_frame) {
		push @document, '\end{frame}';
	    }
	    $in_frame = 0;
	    push @document, '\section{'.$1.'}';
	} elsif (/^---(.*?)\s*---$/) {
	    # New slide.

	    # if there are any running list of items, terminate them as 
	    # we are starting a new slide (a new frame)
	    &terminate_lists();

	    if ($in_frame) {
		push @document, '\end{frame}';
	    }
	    
	    # fragile is needed for when the slides contain verbatim text
	    push @document, '\begin{frame}[fragile]';
	    push @document, '\frametitle{'.$1.'}';
	    $in_frame = 1;
	} elsif (/^( *)([*#]|\d+\.) (.*)/) {
	    # Handle list of items

	    my $num_spaces = length($1);
	    my $type;
	    if ($2 eq '*') {
		$type = 'itemize';
	    } else {
		$type = 'enumerate';
	    }
	    my $item = $3;

	    if (!@list_type) {
		# we are not in any list yet
		push @list_type, $type;
		push @document, '\begin{'.$type.'}';
		push @list_level, $num_spaces;

		push @document, '\item '.$3;
	    } else {
		# we are already inside a list
		if ($list_type[$#list_type] eq $type) {
		    # same type of list: check the level of indentation
		    if ($list_level[$#list_level] < $num_spaces) {
			# go down to a level
			push @list_type, $type;
			push @list_level, $num_spaces;
			push @document, '\begin{'.$type.'}';
			push @document, '\item '.$3;
		    } elsif ($list_level[$#list_level] > $num_spaces) {
			# go up a number of levels
			while ($num_spaces < $list_level[$#list_level]) {
			    pop @list_level;
			    my $top_type = pop @list_type;
			    push @document, '\end{' . $top_type . '}';
			}
			push @document, '\item '.$3;
		    } else {
			# $list_level[$#list_level] == $num_spaces
			# i.e. we are at the same level
			push @document, '\item '.$3;
		    }
		} else {
		    # different type of list: we have to terminate the previous
		    # list and start a new one.

		    # terminate the previous list;
		    pop @list_level;
		    my $top_type = pop @list_type;
		    push @document, '\end{'.$top_type.'}';

		    # start a new one
		    push @list_level, $num_spaces;
		    push @list_type, $type;
		    push @document, '\begin{'.$type.'}';

		    push @document, '\item '.$3;
		}
	    }
	    
	    # end of handling lists

	} elsif (/\[((\d+)%)?\s*([^\]]+\.(png|pdf|jpg))\s*\]/) {
	    # images
	    
	    my $scale;
	    if ($2) {
		$scale = $2;
		$scale = $scale * 0.01; # scale is in percentage
	    } else {
		$scale = 1.0;
	    }
	    my $picture_name = $3;

	    push @document, '\begin{figure}';
	    push @document, '\centering';
	    push @document, '\includegraphics[scale='.$scale.']{'.$picture_name.'}';
	    push @document, '\end{figure}';
	    
	} else {
	    # print $_;
	    &terminate_lists();
	    push @document, $_;
	}
    }
}

# terminate the document properly (by terminating all lists and closing the
# current frame and the document).
&terminate_lists();
if ($in_frame) {
    push @document, '\end{frame}';
}

push @document, '\end{document}';


# generate the final document by appending \n to each line
# and printing each part
print join('', &add_line_return(@pre_document));
print join('', &add_line_return(@title));
print join('', &add_line_return(@document));
