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
    nCols      = params.nCols     ; 
    nVols      = params.nVols     ;        
    vFlBo      = params.volFlBo   ;   
    daeModCur  = params.daeModel  ;
    cstrHt     = params.cstrHt    ; 
    partCoefHp = params.partCoefHp;
    sColNums   = params.sColNums  ;
    nRows      = params.nRows     ;
    valConT    = params.valConT   ;
    
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
    vFlCol0 = zeros(nRows,nCols*(nVols+1));
    
    %Initialize numeric arrays for the pseudo volumetric flow rates for the
    %adsorption columns
    vFlPlus0  = zeros(nRows,nCols*(nVols+1));
    vFlMinus0 = zeros(nRows,nCols*(nVols+1));
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

%             %-------------------------------------------------------------%
%             %Unpack additional params
%             coefMat = params.coefMat{i,nS}{1};
%             %-------------------------------------------------------------%                        
            
            
            
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
            rhsVec = -partCoefHp*cstrHt ...
                  ./ col.(sColNums{i}).gasConsTot ...
                  .* col.(sColNums{i}).adsRatSum;
%             rhsVec0 = rhsVec;
            %-------------------------------------------------------------%                                                 

            
            
            %-------------------------------------------------------------%
            %Define matrix sparsity pattern and the boundary condition

            %If we have a boundary condition at the feed-end
            if feEndBC == 1
                
                %---------------------------------------------------------%
                %Get boundary conditions

                %Take account for the boundary condition on the right hand 
                %side vector
                vFlBoRhs = vFlBo{2,i,nS}(params,col,feTa,raTa,exTa,nS,i);
                
                %Call the helper function to calculate the pseudo 
                %volumetric flow rates
                [vPlusBo,vMinusBo] = calcPseudoVolFlows(vFlBoRhs);
                
                %Update the pseudo volumetric flow rate matrices
                vFlPlus(:,1)  = vPlusBo ;
                vFlMinus(:,1) = vMinusBo;
                %---------------------------------------------------------%
                
                
                
%                 %---------------------------------------------------------%
%                 %Update the right hand side vector
%                 rhsVec0(:,1) = vFlBoRhs + rhsVec0(:,1);
%                 %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Calculate the pseudo volumetric flow rates
                
                %For each CSTR,
                for j = 1 : nVols
                    
                    %Update the right hand side vector
                    rhsVecEval = rhsVec(:,j) ...
                               + vFlPlus(:,j) ...
                               - vFlMinus(:,j);
                      
                    %Determine the flow direction
                    flowDir = (rhsVecEval >= 0);
                    
                    %Compute the pseudo volumetric flow rates
                    vFlPlus(:,j+1)  = rhsVecEval ...
                                   .* flowDir ;
                    vFlMinus(:,j+1) = (-1)*rhsVecEval ...
                                   .* (1-flowDir);
                    
                end        
                
                vFlPlus0  = vFlPlus ;
                vFlMinus0 = vFlMinus;
                %---------------------------------------------------------%
                
            %Else, we have a boundary condition at the product-end
            else
                
                %---------------------------------------------------------%
                %Get boundary conditions
                
                %Take account for the boundary condition on the right hand 
                %side vector
                vFlBoRhs = vFlBo{1,i,nS}(params,col,feTa,raTa,exTa,nS,i);
                
                %Call the helper function to calculate the pseudo 
                %volumetric flow rates
                [vPlusBo,vMinusBo] = calcPseudoVolFlows(vFlBoRhs);
                
                %Update the pseudo volumetric flow rate matrices
                vFlPlus(:,nVols+1)  = vPlusBo ;
                vFlMinus(:,nVols+1) = vMinusBo;
                %---------------------------------------------------------%
                
                
                                
%                 %---------------------------------------------------------%
%                 %Update the right hand side vector
%                 rhsVec0(:,nVols) = -vFlBoRhs + rhsVec0(:,nVols);
%                 %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Calculate the pseudo volumetric flow rates
                
                %For each CSTR,
                for j = nVols : -1 : 1
                    
                    %Update the right hand side vector
                    rhsVecEval = rhsVec(:,j) ...
                               - vFlPlus(:,j+1) ...
                               + vFlMinus(:,j+1);
                    
                    %Determine the flow direction
                    flowDir = (rhsVecEval >= 0);
                    
                    %Compute the pseudo volumetric flow rates
                    vFlPlus(:,j)  = (-1)*rhsVecEval ...
                                 .* (1-flowDir) ;
                    vFlMinus(:,j) = rhsVecEval ...
                                 .* flowDir;
                    
                end 
                
                vFlPlus0  = vFlPlus ;
                vFlMinus0 = vFlMinus;
                %---------------------------------------------------------%              
                
            end
            
            %-------------------------------------------------------------%                              
            
            
                                                                                                                     
%             %-------------------------------------------------------------%                              
%             %Solve for the unknown volumetric flow rates 
%             
%             %Solve for dimensionless volumetric flow rates using a linear
%             %solver           
%             vFl0 = mldivide(coefMat, rhsVec0');            
%             %-------------------------------------------------------------%                              
            
            
            
%             %-------------------------------------------------------------%                              
%             %Save the results
%             
%             %Concatenate the boundary conditions
%             
%             %If we have a boundary condition at the feed end 
%             if feEndBC == 1
%                 
%                 %We are specifying a volumetric flow rate at the feed-end
%                 vFl0 = [vFlBoRhs, vFl0'];
%                 
%             %Else, we have a boundary condition at the product end     
%             else
%                 
%                 %We are specifying a volumetric flow rate at the 
%                 %product-end
%                 vFl0 = [vFl0', vFlBoRhs];
%                 
%             end
%             
%             %Save the volumetric flow rate calculated results
%             vFlCol0(:,(nVols+1)*(i-1)+1:(nVols+1)*i) = vFl0;
%             
%             %Call the helper function to calculate the pseudo volumetric 
%             %flow rates
%             [vPlus0,vMinus0] = calcPseudoVolFlows(vFlCol0); 
%             
%             %Save the pseudo volumetric flow rates
%             vFlPlus0(:,(nVols+1)*(i-1)+1:(nVols+1)*i)  = vPlus0 ;
%             vFlMinus0(:,(nVols+1)*(i-1)+1:(nVols+1)*i) = vMinus0;
%             %-------------------------------------------------------------%                              
            
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
            rhsVec0 = -partCoefHp...
                  ./ col.(sColNums{i}).gasConsTot(:,2:nVols) ...
                  .* diff(col.(sColNums{i}).adsRatSum,1,2);
                             
            %Add the feed-end boundary condition for the ith column in nS
            %step in a given PSA cycle
            rhsVec0(:,1) = ...
                        + rhsVec0(:,1) ...
                        - vFlBoFe/cstrHt(1);
                        
            %Add the product-end boundary condition for the ith column in
            %nS step in a given PSA cycle
            rhsVec0(:,end) = ...
                          + rhsVec0(:,end) ...
                          - vFlBoPr/cstrHt(end);                        
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Solve for the unknown volumetric flow rates
            
            %Solve L(Ux)=b for y where Ly=b with y = Ux            
            vFl0 = mldivide(coefMatLo,rhsVec0');

            %Solve Ux = y for x                                  
            vFl0 = mldivide(coefMatUp,vFl0);
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Save the results
            
            %Concateante the results
            vFl0 = [vFlBoFe,vFl0',vFlBoPr];
            
            %Save the volumetric flow rate calculated results
            vFlCol0(:,(nVols+1)*(i-1)+1:(nVols+1)*i) = vFl0;
            
            %Call the helper function to calculate the pseudo volumetric 
            %flow rates
            [vPlus0,vMinus0] = calcPseudoVolFlows(vFlCol0); 
            
            %Save the pseudo volumetric flow rates
            vFlPlus0(:,(nVols+1)*(i-1)+1:(nVols+1)*i)  = vPlus0 ;
            vFlMinus0(:,(nVols+1)*(i-1)+1:(nVols+1)*i) = vMinus0;
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
    units = calcVolFlows4PFD(params,units,vFlPlus0,vFlMinus0,nS);
    %---------------------------------------------------------------------%                                   
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%