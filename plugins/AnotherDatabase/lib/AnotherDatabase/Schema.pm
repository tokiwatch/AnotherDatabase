package Schema;

use base 'DBIx::Class::Schema::Loader';

__PACKAGE__->loader_options(
    debug => 1,
    naming => 'current',
    quiet => 1,
);
