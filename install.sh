#!/bin/sh

MIX_ENV=prod mix deps.get
#MIX_ENV=prod mix deps.update --all
MIX_ENV=prod mix deps.compile
MIX_ENV=prod mix compile
MIX_ENV=prod mix ecto.create
MIX_ENV=prod mix ecto.migrate
node_modules/brunch/bin/brunch build --production
MIX_ENV=prod mix phoenix.digest
#MIX_ENV=prod PORT=4000 DOMAIN=chargell.ir mix run priv/scripts/add_pins.exs
MIX_ENV=prod PORT=4000 DOMAIN=chargell.ir mix phoenix.server

