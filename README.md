# koha-plugin-availabilityapi

At this stage, this is a toy project for creating a __useful__ API for Koha. It is
focused on retrieving information from Koha.

## Implemented endpoints

* GET  /biblios/_:biblio_id_/allows_hold
* GET  /biblios/_:biblio_id_/allows_checkout
* GET  /items/_:item_id_/allows_hold
* GET  /items/_:item_id_/allows_checkout

## Install

Download the latest _.kpz_ file from the [releases](https://github.com/xmorave2/koha-plugin-availabilityapi/releases) page.
Install it as any other plugin following the general [plugin install instructions](https://wiki.koha-community.org/wiki/Koha_plugins).

Caveat: If you want to try this endpoints, you will need to do it on top of the [Koha master branch](https://gitlab.com/koha-community/Koha)
