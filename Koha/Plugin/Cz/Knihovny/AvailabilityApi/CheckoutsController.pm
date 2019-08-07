package Koha::Plugin::Cz::Knihovny::AvailabilityApi::CheckoutsController;

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
use Mojo::JSON;

use Koha::Biblios;
use Koha::Checkouts;
use Koha::Holds;
use Koha::Item::Transfers;
use Koha::Items;
use Koha::Patrons;
use Koha::Libraries;

=head1 Koha::Plugin::Cz::Knihovny::AvailabilityApi::CheckoutsController

A class implementing the controller methods for checking checkouts availability API

=head2 Class Methods

=head3 get_biblio_checkout_availability

Method to get checkout availability of biblio

=cut

sub get_biblio_checkout_availability {
    my $c = shift->openapi->valid_input or return;

    my $biblio_id = $c->validation->param('biblio_id');
    my $biblio    = Koha::Biblios->find($biblio_id);

    unless ($biblio) {
        return $c->render( status => 404, openapi => { error => "Object not found." } );
    }

    my $availabilities = {};

    my $items = $biblio->items;
    while ( my $i = $items->next ) {
        $availabilities->{$i->itemnumber} = _item_availability( $i );
    }

    return $c->render( status => 200, openapi => $availabilities );
}

=head3 get_item_checkout_availability

=cut

sub get_item_checkout_availability {
    my $c = shift->openapi->valid_input or return;

    my $item_id = $c->validation->param('item_id');
    my $item    = Koha::Items->find($item_id);

    unless ($item) {
        return $c->render( status => 404, openapi => { error => "Object not found." } );
    }

    return $c->render( status => 200, openapi => _item_availability( $item ) );
}

=head2 Internal methods

=head3 _item_availability

=cut

sub _item_availability {
    my ( $item ) = @_;

    my $checkout = Koha::Checkouts->find({ itemnumber => $item->itemnumber });
    my $waiting_holds = Koha::Holds->count({ itemnumber => $item->itemnumber, found => { in => [ "W", "T" ] } } );
    my $transfers = Koha::Item::Transfers->count({ itemnumber => $item->itemnumber, datearrived => undef });

    my $status = 'on_shelf';
    $status = 'in_transfer' if $transfers;
    $status = 'waiting_hold' if $waiting_holds;
    $status = 'checked_out' if $checkout;

    my $availability = {
        allows_checkout => ($checkout || $waiting_holds || $transfers ) ? Mojo::JSON::false : Mojo::JSON->true,
        allows_checkout_status => $status,
    };

    $availability->{date_due} = $checkout->date_due if $checkout;

    return $availability;
}

1;
