function [ x ] = parameterScaler( x )
    
    x2Min = log10( 1.2 );
    x2Max = log10( 20000 );

    x3Min = -10;
    x3Max = log10( 100 );

    x4Min = 0;
    x4Max = 45;

    x5Min = 10^(-10);
    x5Max = 0.99;

    x6Min = 10^(-10);
    x6Max = 1;

    x7Min = 0.05;
    x7Max = 0.9;

    x8Min = 0.01;
    x8Max = 0.5;

    x9Min = 0.01;
    x9Max = 0.6;

    x10Min = 0;
    x10Max = 0.15;

    x11Min = 0;
    x11Max = 0.15;

    x12Min = 0;
    x12Max = 0.2;
    
    x13Min = 0.2;
    x13Max = 1;

    x14Min = 0;
    x14Max = 100;

    x15Min = 0;
    x15Max = 0.5;

    x16Min = 0;
    x16Max = 0.5;

    x17Min = -10;
    x17Max = log10( 100000 );

    x18Min = -10;
    x18Max = log10( 100000 );

    x(2) = scaleX( x, 2, x2Min, x2Max);
    x(3) = scaleX( x, 3, x3Min, x3Max);
    x(4) = scaleX( x, 4, x4Min, x4Max);
    x(5) = scaleX( x, 5, x5Min, x5Max);
    x(6) = scaleX( x, 6, x6Min, x6Max);
    x(7) = scaleX( x, 7, x7Min, x7Max);
    x(8) = scaleX( x, 8, x8Min, x8Max);
    x(9) = scaleX( x, 9, x9Min, x9Max);
    x(10) = scaleX( x, 10, x10Min, x10Max);
    x(11) = scaleX( x, 11, x11Min, x11Max);
    x(12) = scaleX( x, 12, x12Min, x12Max);
    x(13) = scaleX( x, 13, x13Min, x13Max);
    x(14) = scaleX( x, 14, x14Min, x14Max);
    x(15) = scaleX( x, 15, x15Min, x15Max);
    x(16) = scaleX( x, 16, x16Min, x16Max);
    x(17) = scaleX( x, 17, x17Min, x17Max);
    x(18) = scaleX( x, 18, x18Min, x18Max);

    x(2) = 10^x(2);
    x(3) = 10^x(3);

    x(17) = 10^x(17);
    x(18) = 10^x(18);
end

function [x] = scaleX( x, index, xMin, xMax)

    x = x( index );
    xInterval = xMax - xMin;

    x = xInterval * x;
    x = x + xMin;
end