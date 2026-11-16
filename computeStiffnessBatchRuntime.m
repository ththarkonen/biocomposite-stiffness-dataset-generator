function [ y ] = computeStiffnessBatchRuntime( x )

    nData = size( x, 1 );
    y = NaN( nData, 5 );

    for ii = 1:nData
        try
            y( ii, : ) = computeStiffnessRuntime( x( ii, : ) );
        catch
            continue
        end

        disp( ii );
    end
end
