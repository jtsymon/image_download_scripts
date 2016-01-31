package Image::4chan;

use strict;
use warnings;
use File::Basename;
use LWP::Simple;
use JSON;
use Data::Dumper;

use base 'Exporter';
our @EXPORT = ();

sub new {
    my ($class, $board, $thread) = @_;
    ref $class and die "Constructor used as object method\n";
    (defined $thread and defined $board) or die "Must have a thread and board\n";
    my $self = bless (
        {
            board  => $board,
            thread => $thread,
            i      => 0
        },
        $class
    );
    return $self;
}

sub handle_post {
    my $self = shift;

    $self->{i}++;
    my $no      = $_->{no};
    my $tim     = $_->{tim};
    my $ext     = $_->{ext};
    my $fname   = $_->{filename};
    return undef unless(defined $no and defined $tim and defined $ext and defined $fname);
    return [
        "http://i.4cdn.org/" . $self->{board} . "/" . $tim . $ext,
        $no . " - " . $fname . $ext
    ];
}

sub get_dir {
    my $self = shift;
    return $self->{board} . ":" . $self->{thread};
}

sub get_files {
    my $self = shift;

    my $page = get("http://a.4cdn.org/" . $self->{board} . "/thread/" . $self->{thread} . ".json")
        or die "Couldn't reach host (or invalid URL)!";

    my @posts = @{(from_json($page))->{'posts'}};

    return map $self->handle_post, @posts;
}

1;
