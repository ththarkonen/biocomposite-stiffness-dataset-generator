function [ y ] = computeStiffness( x )
    
    % BIOCOMPOSITE STIFFNESS HOMOGENIZATION TRAINING DATA GENERATION
    % Update and cleaned up, September 2024
    % setup for training set generation for AI modeling of Teemu @ Aalto
    
%     clear; clc; close all;
    warning off %otherwise constant Mori-Tanaka issue

    xTotal = x(8) + x(9) + x(10) + x(12);
    xExtractives = x(11);

    if xTotal <= xExtractives
        y = NaN;
        return
    end

    xMicroscopic = x( 7:12 );
    xMicroscopic = xMicroscopic / sum( xMicroscopic );

    x( 7:12 ) = xMicroscopic;
    
    % Input
    %C)fiber macroscopic
    comp.fib.ardis='single'; %optional, aspect ratio distribution: "single","normal","lognormal", "weibull", "uniform", default is single
    comp.fib.ori = distributionMapping( x(1) ); %mandatory, either 'vMF', "vMs"
    comp.fib.ar = x(2); % 2-element vector, optional, defining the aspect ratio distribution function, could be [ar, NaN] with ar as the mean aspect ratio
    comp.fib.oripar = x(3); %orientation distribution parameter (concentration), kappa [-]
    
    %D)fiber microscopic
    comp.fib.MFA = x(4); %optional, microfibril angle [degrees]
    comp.fib.lumpor = x(5); %optional, lumen porosity [-]
    comp.fib.vfrac = x(6); %optional/mandatory, volume fraction of fiber [-], note that either mass or volume fraction has to be given
    comp.fib.mchem.totcel = x(7); %optional, total cellulose (amorph+crystalline) content [-], w.r.t. cell wall mass, note if one is given, all have to be given
    comp.fib.mchem.hemcel = x(8); %optional, hemicellulose content [-], w.r.t. cell wall mass
    comp.fib.mchem.lignin = x(9); %optional, lignin content [-], w.r.t. cell wall mass
    comp.fib.mchem.pectin = x(10); %optional, pectin content [-], w.r.t. cell wall mass
    comp.fib.mchem.extr = x(11); %optional, extractives content [-], w.r.t. cell wall mass
    comp.fib.mchem.ash = x(12); %optional, ash content [-], w.r.t. cell wall mass
    comp.fib.CI = x(13); %optional, crystallinity of cellulose [-]
    
    %E)matrix
    comp.mat.E = x(14); %optional, matrix modulus [GPa]
    comp.mat.nu = x(15); %optional, matrix Poisson's ratio [-], note that stiffness of matrix has to be defined, so if not in the database, it has to be defined here
    comp.mat.fair = x(16); %optional, air porosity [-], default is zero
    
    %F) interface
    comp.IF.mode = 1; % empty or 0...perfect bond, 1...imperfect bond
    comp.IF.par = [ x(17), x(18)]; % two-element vector with interface compliances [alpha, beta], tangential and longitudinal compliance in 1/GPa, attention: normalization w.r.t. fiber radius, actually m/GPa if not normalized in R function
    
    % Input, do not modify
    comp.name=sprintf('Data_%s', datestr(now,'mm-dd-yyyy_HH-MM')); %Name, string
    tol=8; %6 for quick computation, better 8 or even 10
    comp.MLar=1e-20; % aspect ratio of Middle lamella/lumen, either infinitely long 1e-20, or smaller [-]
    comp.fib.mchem.wax=0; %optional, wax content [-], w.r.t. cell wall mass%comp.fib.name='Flax'; %mandatory, name of the fiber; to find it in the database
    
    

    % define composition/microstructure parameters based on input
    comp=prep_comp_AI(comp);
    
    % Homogenization
    [RVE]=hom_biocomp_stiffness(comp,tol);
    
    % Output of 5 parameters
    comp.hom.C=RVE.comp.Chom;
    comp.hom.Cfib=RVE.fib.Chom;
    D=inv(comp.hom.C);

    E_T=1/D(1,1);
    E_L=1/D(3,3);
    nu_T=-D(1,2)*E_T;
    nu_LT=-D(1,3)*E_L;
    mu_LT=1/D(4,4);

    y = [ E_T ,E_L, nu_T, nu_LT, mu_LT];
end

function [d] = distributionMapping( x )
    
    if x == 0
        d = "vMs";
    elseif x == 1
        d = "vMF";
    else
        error("Invalid value for the type of orientation distribution. Must be either 0 (vMF) or 1 (vMs).")
    end
end
