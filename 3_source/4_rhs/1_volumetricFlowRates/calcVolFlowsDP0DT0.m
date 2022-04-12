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
%Code created on       : 2021/1/24/Sunday
%Code last modified on : 2022/4/11/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcVolFlowsDP0DT0.m
%Source     : common
%Description: This function calculates volumetric flow rates (algebraic
%             relationships) that is required to implement either constant
%             pressure DAE model or time varying pressure DAE model, for a
%             given column undergoing a given step in a PSA cycle. The
%             assumption in this model is that there is no pressure drop,
%             i.e., DP = 0, and there is no temperature change, i.e., DT =
%             0.
%Inputs     : params       - a struct containing simulation parameters.
%             units        - a nested structure containing all the units in
%                            the process flow diagram. 
%             nS           - jth step in a given PSA cycle
%Outputs    : units        - a nested structure containing all the units in
%                            the process flow diagram.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function units = calcVolFlowsDP0DT0(params,units,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcVolFlowsDP0DT0.m';
    
    %Unpack params   
    nCols     = params.nCols    ; 
    nVols     = params.nVols    ;        
    vFlBo     = params.volFlBo  ;   
    daeModCur = params.daeModel ;
    cstrHt    = params.cstrHt   ; 
    partCoef  = params.partCoef ;
    sColNums  = params.sColNums ;
    nRows     = params.nRows    ;
    valConT   = params.valConT  ;
    
    %Unpack units
    col  = units.col ;
    feTa = units.feTa;
    raTa = units.raTa;
    exTa = units.exTa;
    %---------------------------------------------------------------------%                                                               
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %A numeric array for the volumetric flow rates for the adsorption
    %columns
    vFlCol = zeros(nRows,nCols*(nVols+1));
    
    %Initialize numeric arrays for the pseudo volumetric flow rates for the
    %adsorption columns
    vFlPlus  = zeros(nRows,nCols*(nVols+1));
    vFlMinus = zeros(nRows,nCols*(nVols+1));
    %---------------------------------------------------------------------% 
                                                
    
    
    %---------------------------------------------------------------------%                            
    %Compute the volumetric flow rates depending on the DAE model being
    %used for a given column undergoing a given step in a given PSA cycle
        
    %For each column
    for i = 1 : nCols
        
        %-----------------------------------------------------------------%
        %If we are dealing with a constant pressure DAE model,
        if daeModCur(i,nS) == 0

            %-------------------------------------------------------------%
            %Unpack additional params
            coefMat = params.coefMat{i,nS}{1};
            %-------------------------------------------------------------%                        
            
            
            
            %-------------------------------------------------------------%
            %Decide which boundary condition is given
            
            %Check if we have a boundary condition specified at the
            %feed-end of the ith adsorber
            feEndBC = valConT(2*(i-1)+1,nS) == 1 && ...
                      valConT(2*i,nS) ~= 1;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%                              
            %Get the right hand side vector at a given time point
            
            %Multiply dimensionless total adsorption rates by the 
            %coefficients that are relevant for the step for ith column            
            rhsVec = -partCoef(i,nS)*cstrHt ...
                  ./ col.(sColNums{i}).gasConsTot ...
                  .* col.(sColNums{i}).adsRatSum;                                                     
            %-------------------------------------------------------------%                                                 
            
            
            
            %-------------------------------------------------------------%
            %Define matrix sparsity pattern and the boundary condition

            %If we have a boundary condition at the feed-end
            if feEndBC == 1

                %Take account for the boundary condition on the right hand 
                %side vector
                vFlBoRhs = vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);
                       
                %Update the right hand side vector
                rhsVec(:,1) = vFlBoRhs + rhsVec(:,1);
            
            %Else, we have a boundary condition at the product-end
            else
                
                %Take account for the boundary condition on the right hand 
                %side vector
                vFlBoRhs = vFlBo{1,i,nS}(params,col,feTa,raTa,exTa,nS,i);
                
                %Update the right hand side vector
                rhsVec(:,nVols) = -vFlBoRhs + rhsVec(:,nVols);
                
            end
            
            %Note that for an isothermal simulation, $\alpha_{n,n-1} \left( 
            %t \right) = -1$ and $\alpha_{n,n} \left( t \right) = 1$,
            %regardless of the flow direction.
            %-------------------------------------------------------------%                              
            
            
                                                                                                                     
            %-------------------------------------------------------------%                              
            %Solve for the unknown volumetric flow rates 
            
            %Solve for dimensionless volumetric flow rates using a linear
            %solver           
            vFl = mldivide(coefMat, rhsVec');            
            %-------------------------------------------------------------%                              
            
            
            
            %-------------------------------------------------------------%                              
            %Save the results
            
            %Concatenate the boundary conditions
            
            %If we have a boundary condition at the feed end 
            if feEndBC == 1
                
                %We are specifying a volumetric flow rate at the feed-end
                vFl = [vFlBoRhs, vFl'];
                
            %Else, we have a boundary condition at the product end     
            else
                
                %We are specifying a volumetric flow rate at the 
                %product-end
                vFl = [vFl', vFlBoRhs];
                
            end
            
            %Save the volumetric flow rate calculated results
            vFlCol(:,(nVols+1)*(i-1)+1:(nVols+1)*i) = vFl;
            
            %Call the helper function to calculate the pseudo volumetric 
            %flow rates
            [vPlus,vMinus] = calcPseudoVolFlows(vFlCol); 
            
            %Save the pseudo volumetric flow rates
            vFlPlus(:,(nVols+1)*(i-1)+1:(nVols+1)*i)  = vPlus ;
            vFlMinus(:,(nVols+1)*(i-1)+1:(nVols+1)*i) = vMinus;
            %-------------------------------------------------------------%                              
            
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %If we are dealing with a time varying pressure DAE model,
        elseif daeModCur(i,nS) == 1

            %-------------------------------------------------------------%
            %Unpack additional params
            coefMatLo = params.coefMat{i,nS}{1}; %Lower triangular matrix
            coefMatUp = params.coefMat{i,nS}{2}; %Upper triangular matrix
            %-------------------------------------------------------------%


            
            %-------------------------------------------------------------%
            %Define the boundary conditions                                     
            
            %Obtain the boundary condition for the product-end of the ith
            %column under current step in a given PSA cycle           
            vFlBoPr = ones(nRows,1) ...
                   .* vFlBo{1,i,nS}(params,col,feTa,raTa,exTa,nS,i);                        
                       
            %Obtain the boundary condition for the feed-end of the ith
            %column under current step in a given PSA cycle
            vFlBoFe = ones(nRows,1) ...
                   .* vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);           
            %-------------------------------------------------------------% 
            
            
            
            %-------------------------------------------------------------%
            %Obtain the right hand side vector for time varying pressure
            %DAE model
            
            %Get the first order difference between adjacent columns of the
            %total adsorption rates for the current ith column            
            rhsVec = -partCoef(i,nS) ...
                  ./ col.(sColNums{i}).gasConsTot(:,2:nVols) ...
                  .* diff(col.(sColNums{i}).adsRatSum,1,2);
                             
            %Add the feed-end boundary condition for the ith column in nS
            %step in a given PSA cycle
            rhsVec(:,1) = ...
                        + rhsVec(:,1) ...
                        - vFlBoFe/cstrHt(1);
                        
            %Add the product-end boundary condition for the ith column in
            %nS step in a given PSA cycle
            rhsVec(:,end) = ...
                          + rhsVec(:,end) ...
                          - vFlBoPr/cstrHt(end);                        
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Solve for the unknown volumetric flow rates
            
            %Solve L(Ux)=b for y where Ly=b with y = Ux            
            vFl = mldivide(coefMatLo,rhsVec');

            %Solve Ux = y for x                                  
            vFl = mldivide(coefMatUp,vFl);
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Save the results
            
            %Concateante the results
            vFl = [vFlBoFe,vFl',vFlBoPr];
            
            %Save the volumetric flow rate calculated results
            vFlCol(:,(nVols+1)*(i-1)+1:(nVols+1)*i) = vFl;
            
            %Call the helper function to calculate the pseudo volumetric 
            %flow rates
            [vPlus,vMinus] = calcPseudoVolFlows(vFlCol); 
            
            %Save the pseudo volumetric flow rates
            vFlPlus(:,(nVols+1)*(i-1)+1:(nVols+1)*i)  = vPlus ;
            vFlMinus(:,(nVols+1)*(i-1)+1:(nVols+1)*i) = vMinus;
            %-------------------------------------------------------------%
            
        end
        %-----------------------------------------------------------------%
        
    end
    %---------------------------------------------------------------------%                                                      
    
    
    
    %---------------------------------------------------------------------% 
    %Determine the volumetric flow rates for the rest of the process flow
    %diagram

    %Grab the unknown volumetric flow rates from the calculated volumetric
    %flow rates from the adsorption columns
    units = calcVolFlows4PFD(params,units,vFlPlus,vFlMinus,nS);
    %---------------------------------------------------------------------%                                   
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%