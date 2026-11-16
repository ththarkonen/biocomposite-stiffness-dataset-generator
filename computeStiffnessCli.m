function computeStiffnessCli( varargin )

    if nargin == 2
        data = load( varargin{ 1 }, 'x' );
        y = computeStiffnessBatchRuntime( data.x );
        save( varargin{ 2 }, 'y', '-v6' );
        return
    end

    x = NaN( 1, 18 );

    for ii = 1:18
        x( ii ) = str2double( varargin{ ii } );
    end

    y = computeStiffnessRuntime( x );

    fprintf( '%.17g %.17g %.17g %.17g %.17g\n', y( 1 ), y( 2 ), y( 3 ), y( 4 ), y( 5 ) );
end
