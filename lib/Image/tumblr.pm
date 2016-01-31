package Image::tumblr;

use strict;
use warnings;
use utf8;

use LWP::Simple;
use JSON;
use Data::Dumper;
use File::Basename;

use base 'Exporter';
our @EXPORT = ();

sub new {
    my ($class, $page) = @_;
    ref $class and die "Constructor used as object method\n";
    (defined $page) or die "Must have a thread and board\n";
    my $self = bless (
        {
            page => $page,
            i    => 0,
            done => 0
        },
        $class
    );
    return $self;
}

sub get_dir {
    my $self = shift;
    return $self->{page};
}

my @sizes = (
    1280,
    500,
    400,
    250,
    100,
    75
);
sub get_photo {
    my $hash = shift;

    for my $size (@sizes) {
        if (exists $hash->{"photo-url-$size"}) {
            my $image = $hash->{"photo-url-$size"};
            return [ $image, basename $image ];
        }
    }
    return undef;
}

sub get_files {
    my $self = shift;

    return () if $self->{done};

    my $url = "http://" . $self->{page} . ".tumblr.com/api/read/json?type=photo&filter=text&num=50";
    my @links;
    my $page = get("$url&start=" . $self->{i}) or die $!;
    my ($json) = ($page =~ /(\{.*\})/);
    my @posts = @{from_json($json)->{posts}};
    if (scalar @posts == 0) {
        $self->{done} = 1;
        return ();
    }
    foreach my $post (@posts) {
        if (exists $post->{photos} and scalar @{$post->{photos}} > 0) {
            foreach my $photo (@{$post->{photos}}) {
                unshift @links, get_photo($photo);
            }
        } else {
            unshift @links, get_photo($post);
        }
    }
    $self->{i} += scalar @posts;
    print $self->{i}, "\n";
    return @links;
}
