use Module::Build;

my $class = Module::Build->subclass( code => <<'EOF',

sub ACTION_test { $_[0]->add_to_cleanup('write_mode.tst'); $_[0]->SUPER::ACTION_test }

EOF
);

my $build =
    $class->new( module_name => 'Log::Dispatch',
                 license     => 'perl',
                 requires    => { 'Params::Validate' => 0.15 },
               );

$build->create_build_script;
