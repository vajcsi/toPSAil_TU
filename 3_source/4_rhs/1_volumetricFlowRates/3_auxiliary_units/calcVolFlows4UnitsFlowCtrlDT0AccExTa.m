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
%Code created on       : 2022/10/22/Saturday
%Code last modified on : 2022/10/22/Saturday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlows4UnitsFlowCtrlDT0AccExTa.m
%Source     : common
%Description: This function calculates volumetric flow rates for the rest
%             of the process flow diagram, based on the calcualted and thus
%             became known volumetric flow rates in the adsorbers. We let
%             the pressure to accumulate inside the extract product tank.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram. 
%             vFlPlus      - a vector containing all the positive pseudo 
%                            volumetric flow rates assocaiated with all the
%                            adsorption columns
%             vFlMinus     - a vector containing all the negative pseudo 
%                            volumetric flow rates assocaiated with all the
%                            adsorption columns
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = calcVolFlows4UnitsFlowCtrlDT0AccExTa(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlows4UnitsFlowCtrlDT0AccExTa.m';
    
    %Unpack params   
    nCols = params.nCols;  
    nRows = params.nRows;
    %---------------------------------------------------------------------%       
    
    
    
    %---------------------------------------------------------------------%
    %Obtain the volumetric flow rates associated with auxiliary units on
    %the process flow diagram.
    
    %Get the volumetric flow rates between the tanks and the adsorbers
    vFlUnits = calcVolFlows4Units(params,units,nS);
    
    %A numeric array for the volumetric flow rates for the feed tank
    vFlFeTa = vFlUnits.feTa;
    
    %A numeric array for the volumetric flow rates for the raffinate 
    %product tank
    vFlRaTa = vFlUnits.raTa;
    
    %A numeric array for the volumetric flow rates for the raffinate waste
    vFlRaWa = vFlUnits.raWa;
    
    %A numeric array for the volumetric flow rates for the extract product 
    %tank
    vFlExTa = vFlUnits.exTa;
    
    %A numeric array for the volumetric flow rates for the extract waste
    vFlExWa = vFlUnits.exWa;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the remaining boundary conditions for the feed tank unit
        
    %The entering valve to the feed tank is always controlled to 
    %maintain a constant pressure inside the feed tank. Therefore, we can 
    %control the volumetric flow rate so that a constant pressure is 
    %maintained inside the feed tank
    vFlFeTa(:,(nCols+1)) = sum(vFlFeTa(:,1:nCols),2);    
    %---------------------------------------------------------------------%       
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the remaining boundary conditions for the raffinate product
    %tank unit
    
    %Get the net volumetric flow rate in the raffinate product tank from 
    %the streams associated with the columns
    vFlNetRaTa = sum(vFlRaTa(:,1:nCols),2);    
    
    %When the raffinate product tank pressure is greater than equal to the 
    %raffinate product pressure and there is a net flow out, maintain it!

    %For each time point t,
    for t = 1 : nRows          
 
            %Obtain the volumetric flow rate out of the constant pressure 
            %regulator valve. The exit valve is opened only when the 
            %raffinate tank pressure equals the raffinate product pressure.
            vFlRaTa(t,(nCols+1)) = vFlNetRaTa(t);
                         
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the remaining boundary conditions for the extract product 
    %tank unit
    
    %Nothing to do here. We let the pressure inside the extract tank
    %accumulate.
    %---------------------------------------------------------------------%
    
    
              
    %---------------------------------------------------------------------% 
    %Save the results to the structs: assign the volumetric flow rates to 
    %the struct holding tank properties
                              
    %Save the volumetric flow rates to a struct
    units.raTa.n1.volFlRat = vFlRaTa;  
    
    %Save the volumetric flow rates to a struct
    units.exTa.n1.volFlRat = vFlExTa;
    
    %Save the volumetric flow rates to a struct
    units.raWa.n1.volFlRat = vFlRaWa;  
    
    %Save the volumetric flow rates to a struct
    units.exWa.n1.volFlRat = vFlExWa;
    
    %Save the volumetric flow rates to a struct
    units.feTa.n1.volFlRat = vFlFeTa;         
    %---------------------------------------------------------------------%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%