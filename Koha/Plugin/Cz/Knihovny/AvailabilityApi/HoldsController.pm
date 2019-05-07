package Koha::Plugin::Cz::Knihovny::AvailabilityApi::HoldsController;

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This program comes with ABSOLUTELY NO WARRANTY;

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use C4::Reserves qw/CanBookBeReserved CanItemBeReserved/;

use Koha::Biblios;
use Koha::Items;
use Koha::Libraries;
use Koha::Patrons;

=head1 Koha::Plugin::Cz::Knihovny::AvailabilityApi::HoldsController

A class implementing the controller methods for checking holds availability API

=head2 Class Methods

=head3 get_biblio_hold_availability

Method to get hold availability of biblio

=cut

sub get_biblio_hold_availability {
    my $c = shift->openapi->valid_input or return;

    my $biblio_id = $c->validation->param('biblio_id');
    my $biblio    = Koha::Biblios->find($biblio_id);
    return $c->render( status => 404, openapi => { error => "Object not found (bibliographic record)." } )
        unless $biblio;

    my $patron_id = $c->validation->param('patron_id');
    my $patron    = Koha::Patrons->find($patron_id);
    return $c->render( status => 404, openapi => { error => "Object not found (patron)." } )
        unless $patron;

    my $library_id = $c->validation->param('library_id');
    my $library    = Koha::Libraries->find($library_id);
    return $c->render( status => 404, openapi => { error => "Object not found (library)." } )
        unless $library;

    my $status = C4::Reserves::CanBookBeReserved($patron_id, $biblio_id, $library_id);

    my $availability = {
        allows_hold => $status->{status} eq "OK" ? Mojo::JSON->true : Mojo::JSON->false
    };

    $availability->{error} = $status->{status} unless $status->{status} eq "OK";

    return $c->render( status => 200, openapi => $availability );
}

=head3 get_item_hold_availability

=cut

sub get_item_hold_availability {
    my $c = shift->openapi->valid_input or return;

    my $item_id = $c->validation->param('item_id');
    my $item    = Koha::Items->find($item_id);
    return $c->render( status => 404, openapi => { error => "Object not found (item)." } )
        unless $item;

    my $patron_id = $c->validation->param('patron_id');
    my $patron    = Koha::Patrons->find($patron_id);
    return $c->render( status => 404, openapi => { error => "Object not found (patron)." } )
        unless $patron;

    my $library_id = $c->validation->param('library_id');
    my $library    = Koha::Libraries->find($library_id);
    return $c->render( status => 404, openapi => { error => "Object not found (library)." } )
        unless $library;

    my $status = C4::Reserves::CanItemBeReserved($patron_id, $item_id, $library_id);

    my $availability = {
        allows_hold => $status->{status} eq "OK" ? Mojo::JSON->true : Mojo::JSON->false
    };

    $availability->{error} = $status->{status} unless $status->{status} eq "OK";

    return $c->render( status => 200, openapi => $availability );
}

=head2 Internal methods

=cut

1;
