%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project Sponsors :
%U.S. Department of Energy 
%American Institute of Chemical Engineers
%Rapid Advancement in Process Intensification Deployment (RAPID) Institute
%Center for Process Modeling (CPM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Contributor(s) :
%Department of Chemical and Biomolecular Engineering,
%Georgia Institute of Technology,
%311 Ferst Drive NW, Atlanta, GA 30332-0100.
%Scott Research Group
%https://www.jkscottresearchgroup.com/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project title :
%Dynamic Modeling and Simulation of Pressure Swing Adsroption (PSA)
%Process Systems
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code by               : Taehun Kim
%Review by             : Taehun Kim
%Code created on       : 2022/2/7/Monday
%Code last modified on : 2022/3/3/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowValOne2RaWa.m
%Source     : common
%Description: a function that calculates a volumetric flow rate after a
%             linear valve located in the product-end of an adsorption
%             column. The flow direction is from an adsorption column to
%             the raffinate waste stream at an ambient pressure.
%Inputs     : params       - a struct containing simulation parameters.
%             col          - a struct containing state variables and
%                            calculated quantities associated with
%                            adsorption columns inside the system.
%             feTa         - a struct containing state variables and
%                            calculated quantities associated with feed
%                            tanks inside the system.
%             raTa         - a struct containing state variables and
%                            calculated quantities associated with product
%                            tanks inside the system.
%             exTa         - a struct containing state variables and
%                            calculated quantities associated with extract 
%                            the product tank inside the system.
%             nS           - jth step in a given PSA cycle
%             nCo          - the column number
%Outputs    : volFlowRat   - a volumetric flow rate after the valve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function volFlowRat = calcVolFlowValOne2RaWa(params,col,~,~,~,nS,nCo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowValOne2RaWa.m';      
    
    %Unpack Params    
    valConNorm   = params.valConNorm  ;
    nAdsVals     = params.nAdsVals    ;
    sColNums     = params.sColNums    ;
    pRatAmb      = params.pRatAmb     ;
    funcVal      = params.funcVal     ;
    tempAmbiNorm = params.tempAmbiNorm;
    
    %Get a dimensionless valve constant value for the product valve (i.e. 
    %valve 1)
    val1Con = valConNorm(nAdsVals*(nCo-1)+1,nS);
    %---------------------------------------------------------------------%                
  
    
    
    %---------------------------------------------------------------------%
    %Get the total concentrations
    
    %Dimensionless total concentration for the Nth CSTR
    gasConTotCol = col.(sColNums{nCo}).gasConsTot(:,end);
    
    %Dimensionless total concentration for the raffinate waste
    gasConTotRaWa = pRatAmb;            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the dimensionless temperatures
        
    %Dimensionless temperature for the last CSTR
    cstrTempCol = col.(sColNums{nCo}).temps.cstr(:,end);
    
    %Dimensionless temperature for the waste stream
    cstrTempRaWa = tempAmbiNorm;  
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the function output
    
    %Calculate the volumetric flow rate after the valve      
    volFlowRat = funcVal(val1Con, ...
                         gasConTotRaWa, ...
                         gasConTotCol, ...
                         cstrTempRaWa, ...
                         cstrTempCol);
    
    %Calculate the volumetric flow rate coming out from the adosrber at the
    %product-end
    volFlowRat = volFlowRat ...
              .* gasConTotRaWa ...
              ./ gasConTotCol;
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%