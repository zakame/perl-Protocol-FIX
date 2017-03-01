use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::Warnings;

use Protocol::FIX::Field;

subtest "STRING" => sub {
    subtest "string filed w/o enumerations" => sub {
        my $f = Protocol::FIX::Field->new(1, 'Account', 'STRING');
        my $s = $f->serialize('abc');
        is $s, '1=abc';

        ok $f->check('abc');
        ok !$f->check(undef);

        ok !$f->check('='), "delimiter is not allowed";
        like exception { $f->serialize('=') }, qr/not acceptable/;
    };

    subtest "string filed with enumerations" => sub {
        my $f = Protocol::FIX::Field->new(5, 'AdvTransType', 'STRING', {
            N => 'NEW',
            C => 'CANCEL',
            R => 'REPLACE',
        });
        is $f->serialize('NEW'), '5=N';

        ok $f->check('NEW');
        ok $f->check('CANCEL');
        ok $f->check('REPLACE');

        ok !$f->check(undef);
        ok !$f->check('NEw');
        ok !$f->check('something else');
    };
};

subtest "INT" => sub {
    subtest "w/o enumerations" => sub {
        my $f = Protocol::FIX::Field->new(68, 'TotNoOrders', 'INT');
        is $f->serialize(5), '68=5';
        ok $f->check(5);
        ok $f->check(-5);

        ok !$f->check("+5");
        ok !$f->check("abc");
        ok !$f->check("");
        ok !$f->check(undef);
    };

    subtest "with enumerations" => sub {
        my $f = Protocol::FIX::Field->new(87, 'AllocStatus', 'INT', {
            0 => 'ACCEPTED',
            1 => 'BLOCK_LEVEL_REJECT',
        });
        is $f->serialize('BLOCK_LEVEL_REJECT'), '87=1';
        ok $f->check('ACCEPTED');

        ok !$f->check(0);
        ok !$f->check(1);
        ok !$f->check("");
        ok !$f->check(undef);
    };
};

subtest "LENGTH" => sub {
    my $f = Protocol::FIX::Field->new(90, 'SecureDataLen', 'LENGTH');
    is $f->serialize(3), '90=3';
    ok $f->check(5);
    ok $f->check(55);

    ok !$f->check(0);
    ok !$f->check(-5);
    ok !$f->check("abc");
    ok !$f->check("");
    ok !$f->check(undef);
};

subtest "DATA" => sub {
    my $f = Protocol::FIX::Field->new(91, 'SecureData', 'DATA');
    is $f->serialize('abc==='), '91=abc===';
    ok $f->check('a');
    ok $f->check("\x01");
    ok $f->check(0);

    ok !$f->check("");
    ok !$f->check(undef);
};

subtest "FLOAT" => sub {
    my $f = Protocol::FIX::Field->new(520, 'ContAmtValue', 'FLOAT');

    ok $f->check(0);
    ok $f->check(3.14);
    ok $f->check(-5);
    ok $f->check("00023.23");
    ok $f->check("23.0000");
    ok $f->check("-23.0");
    ok $f->check("23.0");

    ok !$f->check("22.2.2");
    ok !$f->check("+1");
    ok !$f->check("abc");
    ok !$f->check("");
    ok !$f->check(undef);

    is $f->serialize('10.00001'), '520=10.00001';

};

subtest "CHAR" => sub {
    my $f = Protocol::FIX::Field->new(13, 'CommType', 'CHAR');

    ok $f->check(0);
    ok $f->check(5);
    ok $f->check('A');
    ok $f->check('a');

    ok !$f->check("ab");
    ok !$f->check('=');
    ok !$f->check("");
    ok !$f->check(undef);

    is $f->serialize('z'), '13=z';
};

subtest "CURRENCY" => sub {
    my $f = Protocol::FIX::Field->new(521, 'ContAmtCurr', 'CURRENCY');

    ok $f->check('USD');
    ok $f->check('JPY');
    ok $f->check('BYN');
    ok $f->check('RUB');

    ok !$f->check("USDJPY");
    ok !$f->check("");
    ok !$f->check(undef);

    is $f->serialize('BYN'), '521=BYN';
};


done_testing;