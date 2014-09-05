package t::TestApp::RedisMock;
use strictures 1;
# ABSTRACT: Redis mock for unit tests.
# COPYRIGHT

BEGIN {
  our $VERSION = '0.001';  # fixed version - NOT handled via DZP::OurPkgVersion.
}

use Moo;
use Dancer2::Core::Types qw( Undef HashRef );

############################################################################

has _storage => (
  is      => 'rwp',
  isa     => HashRef,
  default => sub { {} },
);

############################################################################

sub get {
  my ( $self, $key ) = @_;
  return unless exists $self->_storage->{$key};
  my $data = $self->_storage->{$key};
  if ( exists $data->{expire} && $data->{expire} < time ) {
    delete $self->_storage->{$key};
    return;
  }
  return $data->{value};
}

############################################################################

sub set {
  my ( $self, $key, $value ) = @_;
  $self->_storage->{$key} = { value => $value };
  return 1;
}

############################################################################

sub expire {
  my ( $self, $key, $expire ) = @_;
  $self->_storage->{$key}->{expire} = time + $expire;
  return 1;
}

############################################################################

sub mget {
  my ( $self, @keys ) = @_;
  my @values;
  push @values, $self->get($_) // undef for (@keys);
  return @values;
}

############################################################################

sub mset {
  my ( $self, %keys_values ) = @_;
  $self->set( $_ => $keys_values{$_} ) for ( keys %keys_values );
  return 1;
}

############################################################################
1;
