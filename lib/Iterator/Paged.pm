
package Iterator::Paged;

use strict;
use warnings 'all';

our $VERSION = '0.002';


#==============================================================================
sub new
{
  my ($class, %args) = @_;
  
  return bless {
    data        => [ ],
    page_number => 0,
    idx         => 0,
    %args,
  }, $class;
}# end new()


#==============================================================================
# Default just returns another random set of 10 digits:
sub next_page { shift->{page_number}++; [ map { rand() } 1..10 ] }


#==============================================================================
sub next
{
  my $s = shift;
  
  if( exists( $s->{data}->[ $s->{idx} ] ) )
  {
    return $s->{data}->[ $s->{idx}++ ];
  }
  else
  {
    # End of the current resultset, see if we can get another page of records:
    if( my $page = $s->next_page )
    {
      push @{ $s->{data} }, @$page;
      return $s->{data}->[ $s->{idx}++ ];
    }
    else
    {
      # No more pages, no more data:
      return;
    }# end if()
  }# end if()
}# end next()


#==============================================================================
sub reset
{
  my $s = shift;
  
  $s->{idx} = 0;
}# end next()


#==============================================================================
sub first
{
  shift->{data}->[0];
}# end first()


#==============================================================================
sub page_number { shift->{page_number} }


1;# return true:

=pod

=head1 NAME

Iterator::Paged - Simple iterator with events for accessing more records.

=head1 SYNOPSIS

  use Iterator::Paged;
  
  my $iter = Iterator::Paged->new();
  while( my $item = $iter->next )
  {
    warn $iter->page_number . ": $item\n";
    last if $iter->page_number > 100;
  }# end while()

Or, more likely, in a subclass:

  package My::Iterator;
  
  use strict;
  use warnings 'all';
  use base 'Iterator::Paged';
  
  sub next_page
  {
    my ($s) = @_;
    
    # Return an arrayref of the next "page" of data:
    return if $s->{page_number}++ >= 4;
    return [ $s->{idx}.. $s->{idx} + 5  ];
  }# end get_page()

Then, using that class:

  use My::Iterator;
  
  my $iter = My::Iterator->new();
  
  while( my $item = $iter->next )
  {
    warn "Page " . $iter->page_number . ": $item\n";
  }# end while()

That last example will print the following:

  Page 1: 0
  Page 1: 1
  Page 1: 2
  Page 1: 3
  Page 1: 4
  Page 1: 5
  Page 2: 6
  Page 2: 7
  Page 2: 8
  Page 2: 9
  Page 2: 10
  Page 2: 11
  Page 3: 12
  Page 3: 13
  Page 3: 14
  Page 3: 15
  Page 3: 16
  Page 3: 17
  Page 4: 18
  Page 4: 19
  Page 4: 20
  Page 4: 21
  Page 4: 22
  Page 4: 23

=head1 DESCRIPTION

Iterator::Paged provides a simple (subclassable) iterator that will attempt to
fetch the next "page" of results when the current set is exhausted.

For example, suppose you have an iterator for results on Google.com that fetches
the first page of results and upon the next call to C<next> fetches the second page,
then third page, fourth and so on.

=head1 AUTHOR

John Drago <jdrago_999@yahoo.com>

=head1 COPYRIGHT

Copyright 2009 John Drago <jdrago_999@yahoo.com> all rights reserved.

=head1 LICENSE

This software is free software and may be used and redistributed under the same
terms as Perl itself.

=cut

