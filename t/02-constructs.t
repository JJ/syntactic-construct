#!/usr/bin/perl
use warnings;
use strict;

use Test::More;

my %tests = (
    5.018 => [
        [ 'computed-labels',
          'my $x = "A"; B:while (1) { A:while (1) { last $x++ }}; 1', 1],
        [ 'our-sub',
          '{our sub xx { 1 } } xx', undef],
        [ 'state-sub',
          '{state sub xx { 1 } } xx', undef],
    ],

    5.014 => [
        [ '?^',
          '"Ab" =~ /(?i)a(?^)b/', 1],
        [ '/r',
          'my $x = "abc"; $x =~ s/c/d/r', 'abd'],
        [ '/a',
          '"\N{U+0e0b}" =~ /^\w$/a', q()],
        [ '/u',
          '"\xa0\xe0" =~ /\w/u', 1],
        [ 'auto-deref',
          'my $x = [10, 20, 30]; join ":", keys $x', "0:1:2"],
        [ 'auto-deref',
          'my $x = {a=>10, b=>20}; join ":", sort keys $x', "a:b"],
        [ 'auto-deref',
          'my $x = [10, 20]; push $x, 30; "@$x"', "10 20 30"],
        [ '^GLOBAL_PHASE',
          '${^GLOBAL_PHASE}', 'RUN'],
    ],

    5.012 => [
        [ 'package-version',
          'package Local::V 4.3; 1', 1],
        [ '...',
          'my $x = 0; if ($x) { ... } else { 1 }', 1],
        [ 'each-array',
          'my $r; my @x = qw(a b c); while (my ($i, $v) = each @x) '
          . ' { $r .= $i . $v; } $r', '0a1b2c'],
        [ 'keys-array',
          'my @x = qw(a b c); join q(), keys @x', '012'],
        [ 'values-array',
          'my @x = qw(a b c); join q(), values @x', 'abc'],
        [ 'delete-local',
          'our %x = (a=>10, b=>20); {delete local $x{a};'
          . ' die if exists $x{a}};$x{a}', 10],
        [ 'length-undef',
          'length undef', undef],
    ],

    5.010 => [
        [ '//',
          'undef // 1', 1],
        [ '?PARNO',
          '"abad" =~ /^(.).(?1).$/', 1],
        [ '?<>',
          '"a1b1" =~ /(?<b>.)b\g{b}/;', 1],
        [ 'quant+',
          '"xaabbaa" =~ /a*+a/;', q()],
        [ 'regex-verbs',
          '', ],
        [ '\K',
          '(my $x = "abc") =~ s/a\Kb/B/; $x', 'aBc'],
        [ '\gN',
          '"aba" =~ /(a)b\g{1}/;', 1],
        [ 'readline()',
          '*ARGV=*DATA; chomp(my $x = readline()); $x', 'readline default'],
        [ 'stack-file-test',
          '-e -f $^X', 1],
        [ 'recursive-sort',
          'sub re {$a->[0] <=> $b->[0] '
          . 'or re(local $a = [$a->[1]], local $b = [$b->[1]])}'
          . 'join q(), map @$_, sort re ([1,2], [1,1], [2,1], [2,0])',
          '11122021'],
        [ '/p',
          '"abc" =~ /b/p;${^PREMATCH}', 'a'],
    ],
);

my $count = 0;
for my $version (keys %tests) {
    my @triples = @{ $tests{$version} };
    if (eval { require ( 0 + $version) }) {
        diag sprintf '%.3f', $version;
        for my $triple (@triples) {
            $count++;
            is(eval("use Syntax::Construct qw($triple->[0]);$triple->[1]"),
               $triple->[2], $triple->[0]);
        }
    }
}

done_testing($count);
__DATA__
readline default