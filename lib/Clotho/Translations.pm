package Clotho::Translations;
use strict;

my %interface = (
   'Search' => {'gr' => 'Αναζήτηση'},
   'Enter keyword in the text box to search through the site pages' => {'gr' => 'Δώστε τον όρο αναζήτησης για το περιεχόμενο των ιστοσελίδων'},
   'Keyword' => {'gr' => 'Όρος'},
   'Case Sensitive' => {'gr' => 'Κεφαλαία-Μικρά γράμματα'},
   'Whole Words Only' => {'gr' => 'Ολόκληρες λέξεις μόνο'},
   'Sort by' => {'gr' => 'Ταξινόμηση με'},
   'Results per page' => {'gr' => 'Αποτελέσματα ανά σελίδα'},
   'Matches' => {'gr' => 'Ομοιότητες'},
   'Scores' => {'gr' => 'Σκόρ'},
   'Dates' => {'gr' => 'Ημερομηνίες'},
   'Sizes' => {'gr' => 'Μεγέθη'},
   'Whole Words Only' => {'gr' => 'Ολόκληρες Λέξεις μόνο'},
   'Search Content' => {'gr' => 'Περιεχόμενο αναζήτησης'},
   'Page Body' => {'gr' => 'Σώμα Σελίδας'},
   'Title' => {'gr' => 'Τίτλος'},
   'Links' => {'gr' => 'Δεσμοί'},
   'Description' => {'gr' => 'Περιγραφή'},
   'Meta-Keywords' => {'gr' => 'Μετα-όροι'},
   'Author' => {'gr' => 'Συγγραφέας'},
   'New Search' => {'gr' => 'Νέα Αναζήτηση'},
   'Sorry, no pages matched your search criteria' => {'gr' => 'Λυπούμαστε, τα κριτήρια αναζήτησής σας δεν επέστρεψαν καμία σελίδα'},
   'Search Results' => {'gr' => 'Αποτελέσματα αναζήτησης'},
   'Previous' => {'gr' => 'Προηγούμενα'},
   'Next' => {'gr' => 'Επόμενα'},
   '' => {'gr' => ''},
   );

sub translate {
   my $text = shift;
   my $lang = shift;
   
   #use "pack" and "unpack" to let PERL know this is already a valid UTF-8 string
   return pack "U0C*", unpack "C*", $interface{$text}{$lang};
}

