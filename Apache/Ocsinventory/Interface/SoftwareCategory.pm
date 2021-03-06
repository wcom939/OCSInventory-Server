###############################################################################
## Copyright 2005-2016 OCSInventory-NG/OCSInventory-Server contributors.
## See the Contributors file for more details about them.
##
## This file is part of OCSInventory-NG/OCSInventory-ocsreports.
##
## OCSInventory-NG/OCSInventory-Server is free software: you can redistribute
## it and/or modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 2 of the License,
## or (at your option) any later version.
##
## OCSInventory-NG/OCSInventory-Server is distributed in the hope that it
## will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with OCSInventory-NG/OCSInventory-ocsreports. if not, write to the
## Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
## MA 02110-1301, USA.
################################################################################
package Apache::Ocsinventory::Interface::SoftwareCategory;

use Apache::Ocsinventory::Map;
use Apache::Ocsinventory::Interface::Database;
use Apache::Ocsinventory::Interface::Internals;

use strict;
use warnings;

require Exporter;

our @ISA = qw /Exporter/;

our @EXPORT = qw /
  _get_category_software
  set_category
/;

sub get_category_software{
    my $dbh = $Apache::Ocsinventory::CURRENT_CONTEXT{'DBI_HANDLE'};
    my $sql;
    my @cats;
    my $result;

    $sql = "SELECT c.ID, c.CATEGORY_NAME, s.SOFTWARE_EXP FROM software_categories c, software_category_exp s WHERE s.CATEGORY_ID = c.ID";
    $result = $dbh->prepare($sql);
    $result->execute;

    while( my $row = $result->fetchrow_hashref() ){
        push @cats, {
            'ID' => $row->{ID},
            'CATEGORY_NAME' => $row->{CATEGORY_NAME},
            'SOFTWARE_EXP' =>  $row->{SOFTWARE_EXP}
        }
    }

    return @cats;
}

sub set_category{
    my $dbh = $Apache::Ocsinventory::CURRENT_CONTEXT{'DBI_HANDLE'};

    my @cats = get_category_software();
    my $soft_cat;
    my $default_cat;

    my $sql = $dbh->prepare("SELECT ivalue FROM config WHERE config.name='DEFAULT_CATEGORY'");
    $sql->execute;
    while (my $row = $sql->fetchrow_hashref()){
        $default_cat = $row->{ivalue};
    }

    foreach my $soft (@{$Apache::Ocsinventory::CURRENT_CONTEXT{'XML_ENTRY'}->{CONTENT}->{SOFTWARES}}){
        foreach my $cat (@cats){
            my $regex = $cat->{SOFTWARE_EXP};
            if ($soft->{NAME} =~ /$regex/) {
                $soft_cat = $cat->{ID};
            }
        }
        if (!defined $soft_cat) {
            $soft_cat = $default_cat;
        }

        $soft->{CATEGORY} = $soft_cat;
        $soft_cat = undef;
    }
    return 1;
}
1;
