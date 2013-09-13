#!/usr/bin/perl -w
use File::Find;
use strict;
use warnings;
sub file_proccess();
sub is_first_rar($);
sub unrar_file($);

my $main_dir = $ARGV[0];

find(\&file_proccess,$main_dir);

sub file_proccess() {
    return if -d;
    my $file_name = $_;
    my $dir_name = $File::Find::dir;
    my $full_file = $File::Find::name;
    if (is_first_rar($file_name)) {
        unrar_file($file_name);
    }
}

sub unrar_file($) {
    my $file_path_safe = shift;
    $file_path_safe =~ s/ /\\ /g;
    $file_path_safe =~ s/([()])/\\$1/g;
    system("unrar e -o- $file_path_safe");
}

sub is_first_rar($) {
    my $file_path = shift;

    # Match the partXX.rar types
    if ($file_path =~ m/\.part(\d\d).rar$/i) {
        my $num = $1;
        return 1 if $num == 0;
        if ($1 == 1) {
            my $part00_in_dir = $file_path;
            $part00_in_dir =~ s/part01.rar$/part00.rar/i;
            return 1 unless -f $part00_in_dir
        }
        return 0;
    }

    # Match the .rar,r00,r01 types
    return 1 if $file_path =~ m/\.rar$/i;
    if ($file_path =~ m/\.r00/i) {
        my $rar_in_dir = $file_path;
        $rar_in_dir =~ s/r00$/rar/i;
        return 1 unless -f $rar_in_dir;
    }
    if ($file_path =~ m/\.r01/i) {
        my $rar_in_dir = $file_path;
        $rar_in_dir =~ s/r01$/rar/i;
        my $r00_in_dir = $file_path;
        $r00_in_dir =~ s/r01$/r00/i;
        return 1 unless ( (-f $rar_in_dir) || (-f $r00_in_dir) );
    }
    return 0;
}
