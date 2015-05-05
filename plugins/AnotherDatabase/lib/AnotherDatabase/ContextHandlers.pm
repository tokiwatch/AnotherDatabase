# $Id$

package AnotherDatabase::ContextHandlers;

use strict;
use warnings;
use Encode;

#----- Tags
sub db_object {
  my ( $ctx, $args, $cond ) = @_;
  my $builder = $ctx->stash('builder');
  my $tokens  = $ctx->stash('tokens');

  my $objectdriver_key = $args->{'objectdriver_key'} ? $args->{'objectdriver_key'} : 'adbobjectdriver';
  my $database_key     = $args->{'database_key'}     ? $args->{'database_key'}     : 'adbdatabase';
  my $dbhost_key       = $args->{'dbhost_key'}       ? $args->{'dbhost_key'}       : 'adbdbhost';
  my $dbuser_key       = $args->{'dbuser_key'}       ? $args->{'dbuser_key'}       : 'adbdbuser';
  my $dbpassword_key   = $args->{'dbpassword_key'}   ? $args->{'dbpassword_key'}   : 'adbdbpassword';
  my $dbencode_key     = $args->{'dbencode'}         ? $args->{'dbencode'}         : 'adbdbencode';

  use MT;
  my $mt     = MT->instance;
  my $objdvr = $mt->config->{'__var'}->{$objectdriver_key};
  my $db     = $mt->config->{'__var'}->{$database_key};
  my $host   = $mt->config->{'__var'}->{$dbhost_key};

  my $dsn = $objdvr . ':' . $db . ';host=' . $host;
  my $usr = $mt->config->{'__var'}->{$dbuser_key};
  my $pwd = $mt->config->{'__var'}->{$dbpassword_key};

  my $encode = $mt->config->{'__var'}->{$dbencode_key};

  my $attrs = {
    AutoCommit        => 1,
    mysql_enable_utf8 => 1,
    on_connect_do     => [ "SET NAMES " . $encode ]
  };

  use AnotherDatabase::Schema;
  my $db_obj = Schema->connect( $dsn, $usr, $pwd, $attrs );

  local $ctx->{__stash}->{another_database} = $db_obj;

  defined( my $out = $builder->build( $ctx, $tokens, $cond ) ) || return $ctx->error( $ctx->errstr );

  return $out;
}

sub filter {
  my ( $ctx, $args, $cond, $table_obj ) = @_;

  my $builder = $ctx->stash('builder');
  my $tokens  = $ctx->stash('tokens');
  my $method  = $args->{'method'};
  my $column  = $args->{'column'};
  my @values  = split( / *, */, $args->{'values'} );

  my %where;

  if ($column) {
    if ($method) {
      if ( $method eq 'between' ) {
        %where = ( $column => { -between => \@values } );
      }
      elsif ( $method eq 'like' ) {
        %where = ( $column => { $method, '%' . $args->{'values'} . '%' } );
      }
      else {
        %where = ( $column => { $method, $args->{'values'} } );
      }
    }
    else {
      %where = ( $column => \@values );
    }
  }

  my $sort_by = $args->{'sort_by'};
  my $sort_order = $args->{'sort_order'} ? $args->{'sort_order'} : 'descend';

  my %term;

  if ($sort_by) {
    my %sort_string;
    %sort_string = ( -desc => $sort_by ) if ( $sort_order eq 'descend' );
    %sort_string = ( -asc  => $sort_by ) if ( $sort_order eq 'ascend' );
    $term{order_by} = \%sort_string;
  }

  $term{page} = $args->{'page'} ? $args->{'page'} : 1;
  $term{rows} = $args->{'rows'} ? $args->{'rows'} : 10;

  my $out = '';

  my $adbf_is_included;

  foreach my $each_token (@$tokens) {
    if ( $each_token->[0] =~ /anotherdatabasefilter/i ) {
      $adbf_is_included = 1;
    }
  }

  if ($adbf_is_included) {
    my $results_rs = $table_obj->search( \%where, \%term );
    $ctx->{__stash}->{another_database_table_rs} = $results_rs;
    $out .= $builder->build( $ctx, $tokens );
  }
  else {
    my @results = $table_obj->search( \%where, \%term );
    foreach my $each_result (@results) {
      local $ctx->{__stash}->{another_database_table} = $each_result->{'_column_data'};
      $out .= $builder->build( $ctx, $tokens );
    }
  }

  return $out;
}

sub table_object {
  my ( $ctx, $args, $cond ) = @_;
  my $table_name = $args->{'table'};
  my $table_obj  = $ctx->stash('another_database')->resultset($table_name);

  filter( $ctx, $args, $cond, $table_obj );
}

sub table_filter {
  my ( $ctx, $args, $cond ) = @_;

  my $table_obj = $ctx->stash('another_database_table_rs');

  filter( $ctx, $args, $cond, $table_obj );
}

sub column_object {
  my ( $ctx, $args ) = @_;
  my $column_name = $args->{'column'};
  my $row         = $ctx->stash('another_database_table');
  my $column      = $row->{$column_name};
  return $column;
}
1;
