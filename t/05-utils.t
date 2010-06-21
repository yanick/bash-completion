#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;

use_ok('Bash::Completion::Utils',
  qw(command_in_path match_perl_modules prefix_match))
  || die "Could not load Bash::Completion::Utils, ";

## command_in_path
ok(command_in_path('perl'), 'command_in_path(perl) works');
ok(
  !command_in_path('non_existing_command'),
  'command_in_path(non_existing_command) also works'
);


## match_perl_modules
my @pm = match_perl_modules('Bash::Comple');
cmp_bag(\@pm, ['Bash::Completion', 'Bash::Completion::']);

@pm = match_perl_modules('Bash::Completion');
cmp_bag(\@pm, ['Bash::Completion', 'Bash::Completion::']);

@pm = match_perl_modules('Bash::Completion::');
cmp_bag(
  \@pm,
  [ 'Bash::Completion::Utils',  'Bash::Completion::Plugins::',
    'Bash::Completion::Plugin', 'Bash::Completion::Request'
  ]
);

@pm = match_perl_modules('Bash::Completion::U');
cmp_bag(\@pm, ['Bash::Completion::Utils']);

@pm = match_perl_modules('Bash::Completion::Uz');
cmp_bag(\@pm, []);

@pm = match_perl_modules('Ba', 'Bash::Completion::Plugins');
cmp_bag(\@pm, ['BashComplete']);

@pm = match_perl_modules('Plugins::Ba', 'Bash::Completion');
cmp_bag(\@pm, ['Plugins::BashComplete']);

{
  ## duplicate our @INC dirs, force it to find multiple copies
  local @INC;
  push @INC, 'lib';

  @pm = match_perl_modules('Plugins::Ba', 'Bash::Completion');
  cmp_bag(\@pm, ['Plugins::BashComplete']);
}

@pm = match_perl_modules('Net');
cmp_bag(\@pm, ['Net::'], 'Let Net expand to Net::');

@pm = match_perl_modules('Net:');
cmp_deeply(\@pm, array_each(re('^Net::.')));


## prefix_match
my @mtchs =
  prefix_match('--h', '--dry', '--help', '--helicopter', '--nothing', '-h');
cmp_bag(\@mtchs, ['--help', '--helicopter'],
  'Matched correct set of options');

@mtchs = prefix_match('a', 'never', 'always', 'perl', 'python', 'antique');
cmp_bag(\@mtchs, ['always', 'antique'], 'Matched correct set of words');


## and we are done for today
done_testing();
