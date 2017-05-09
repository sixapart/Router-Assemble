requires 'perl', '5.010001';

requires 'List::Util';
requires 'Regexp::Assemble', '0.35';

on test => sub {
    requires 'Test::Deep';
    requires 'Test::More', '0.98';
};

on develop => sub {
    requires 'Test::CPAN::Meta';
    requires 'Test::MinimumVersion::Fast', '0.04';
    requires 'Test::PAUSE::Permissions', '0.04';
    requires 'Test::Pod', '1.41';
    requires 'Test::Spellunker', 'v0.2.7';
};
