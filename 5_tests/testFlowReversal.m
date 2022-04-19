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
%Code created on       : 2022/4/17/Sunday
%Code last modified on : 2022/4/17/Sunday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : testFlowReversal.m
%Source     : common
%Description: test out the assumption made in the DAE system. In other
%             words, given a state solution at a given time point, we
%             compute the constraint c_n (t) \frac{d T_n (t)}{d t} + T_n
%             (t) \frac{d c_n (t)}{d t}, for all n in \left\{ 1, ..., n_c 
%             \right}.
%Inputs     : t            - a current time point at which the numerical
%                            integration of the ODE finished successfully
%             y            - a state solution of a successful numerical
%                            integration at time t
%             flags        - the function responds to the following flags:
%                            'init', '[]', and 'done'
%Outputs    : status       - 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function status = testFlowReversal(t,y,flag,varargin)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'testFlowReversal.m';
    %---------------------------------------------------------------------%                 
    
    
    
    %---------------------------------------------------------------------% 
    %Depending on the input specifications, carry out necessary
    %calculations for the customized OutputFnc
    
    %In the case where no additional parameters are specified as function
    %input, we just impelement odeprint which is a default OutputFnc in
    %MATLAB
    %odeprint(t,y) or odeprint(t,y,'')
    if nargin < 3 && isempty(flag) 
        
        %Clear the Command Window
        clc
        
        %Plot the time and the states in the Command Window
        t  
        y 
        
    %When we are dealing with an additional input struct, we would like to
    %evaluate a specific quantity using the state solution from a
    %successful or "correct" numerical integration of the ODEs at time t
    elseif nargin == 6 && isempty(flag) 
        
        %-----------------------------------------------------------------% 
        %Unpack additional params

        %Unpack the first additional params (this should be a struct)
        params = varargin{1};
        
        %Unpack the current step number
        nS = varargin{2};
        
        %Unpack the current cycle number
        nCy = varargin{3};

        %Unpack params              
        funcVol = params.funcVol;
        nSteps  = params.nSteps ;

        %Save needed quantity: We are just concerned with a single time
        %point inside the RhS function
        params.nRows = 1;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%                            
        %Check function inputs

        %Convert the states to a row vector
        y = y(:).';
        %-----------------------------------------------------------------%                            
    
    
    
        %-----------------------------------------------------------------%
        %Given a state vector, convert it to respective state variables
        %associated with each columns and tanks    

        %Create an object for the columns
        units.col = makeColumns(params,y);

        %Create an object for the feed tanks
        units.feTa = makeFeedTank(params,y);

        %Create an object for the raffinate product tanks
        units.raTa = makeRaffTank(params,y);  

        %Create an object for the extract product tanks
        units.exTa = makeExtrTank(params,y); 
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Define the inter-unit interactions in a given process flow diagram    

        %Update adsorption column structures to contain interactions
        %between units down or upstream
        units = makeCol2Interact(params,units,nS);

        %Based on the volumetric flow function handle, obtain the 
        %corresponding volumetric flow rates associated with the adsorption
        %columns
        units = funcVol(params,units,nS);
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Calculate the pseudo volumetric flow rates in the first adsorption
        %column
        
        %Call the helper function to calculate the pseudo volumetric flow 
        %rates
        [vFlPlus,vFlMinus] = calcPseudoVolFlows(units.col.n1.volFlRat);        
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check to see if there is flow reversal
       
        %Compute the sums
        sumPlus  = sum(vFlPlus);
        sumMinus = sum(vFlMinus);
        
        %Compare the sum and see if at least one of them is zero
        
        %If the sum of the positive pseudo volumetric flow rates is zero
        if sumPlus == 0 
            
            %Print unity
            1
            
        %If the sum of the negative pseudo volumetric flow rates is zero    
        elseif sumMinus == 0
            
            %Print a negative unity
            -1
            
        %If no sums for the pseudo volumetric flow rates are zero
        else
            
            %Print zero
            0
            
        end                        
        %-----------------------------------------------------------------%
     
    %When there is a flag that is non-empty
    else
        
        
        %Check the flag data type
        if isstring(flag) && isscalar(flag)

          %Convert the data type into a character
          flag = char(flag);

        end
      
        %Switch among several cases based on expression
        switch(flag)
       
        %odeprint(tspan,y0,'init')
        case 'init'               

            %Clear the Command Window
            clc
          
            %Plot the time and the states in the Command Window
            t = t(1)
            y 

        %odeprint([],[],'done')
        case 'done'   

            %Skip the line in the Command Window
            fprintf('\n\n');

        end

    end
    %---------------------------------------------------------------------% 

    
    
    %---------------------------------------------------------------------%
    %Return the status
    
    %The status is, by default, equal to zero
    status = 0;
    %---------------------------------------------------------------------%

end