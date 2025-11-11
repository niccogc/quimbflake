(import (
  fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
    sha256 = "0pf91b1xwgmnvqj9dwcfdzdgw4qw8xrv8b4l4h32b6aw48l1f4wg";
  }
) {
  src = ./.;
}).defaultNix
