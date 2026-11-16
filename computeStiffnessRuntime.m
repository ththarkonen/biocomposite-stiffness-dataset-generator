function [ y ] = computeStiffnessRuntime( x )

    if isdeployed
        rootPath = ctfroot;
    else
        rootPath = fileparts( mfilename( 'fullpath' ) );
        addpath( rootPath, ...
            fullfile( rootPath, 'basics' ), ...
            fullfile( rootPath, 'hill' ), ...
            fullfile( rootPath, 'homogenization' ), ...
            fullfile( rootPath, 'material' ) );
    end

    y = computeStiffness( x );
end
