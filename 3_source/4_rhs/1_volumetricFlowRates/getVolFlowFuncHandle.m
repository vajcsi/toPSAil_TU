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
%Code created on       : 2021/1/26/Tuesday
%Code last modified on : 2022/8/8/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getVolFlowFuncHandle.m
%Source     : common
%Description: a function that grabs a corresponding function handle for the
%             boundary condition for "nS" th step, "numCol" th column, and 
%             "numBo" th boundary condition.
%Inputs     : params       - a struct containing simulation parameters.
%             numSte       - the current number of the step.
%             numCol       - the column number
%             numBo        - the current boundary condition number (1 means
%                            product-end and 2 means feed-end).            
%Outputs    : funcHandle   - a function handle that returns the
%                            corresponding boundary condition for the
%                            situation.
%             flags        - a structure with information about the
%                            boundary conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [funcHandle,flags] ...
    = getVolFlowFuncHandle(params,numStep,numCol,numBo)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    funcId = 'getVolFlowFuncHandle.m';
    
    %Unpack Params      
    bool     = params.bool    ;
    typeCol  = params.typeCol ;
    sStepCol = params.sStepCol;

    %Check to see if the step has a momentum balance
    simMode = bool(6);

    %Check to see if we have a time varying vs. constant pressure step
    typeColStep = typeCol(numCol,numStep);

    %Check the name of the current step at the current adsorption column
    stepNameCurr = sStepCol{numCol,numStep};
    %---------------------------------------------------------------------%                
    
    
    
    %---------------------------------------------------------------------%
    %Based on the given simulation mode, assign proper boundary conditions
 
    %When we are working with "flow-controlled" simulation mode
    if simMode == 0

        %
        if typeColStep == 1        

            %
            if strcmp(stepNameCurr,'HP-FEE-ATM')
    
                
                




    
            end

        %
        elseif typeColStep == 0
            


        end



    
    %When we are working with "pressure-driven" simulation mode
    elseif simMode == 1








    %When the user specified not a boolean variable
    else

        %Print warnings
        msg1 = 'Please provide a boolean value of either 0 or 1 ';
        msg2 = 'to indicate flow-controlled (0) vs. ';
        msg3 = 'pressure-driven (1) simulation mode';
        msg = append(funcId,': ',msg1,msg2,msg3);
        error(msg);

    end
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Based on the conditions, decide the value of function handle for the
    %current situation in terms of nS, numCol, and numBo                

        %-----------------------------------------------------------------%
        %Check for the completely closed valves
        
        %If all the product-end valves are closed, assign the function 
        %handle a value of zero
        if topClosed && numBo == 1

            %Define the function handle to be a constant value of zero
            funcHandle = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
            
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;

        %If all the feed-end valves are closed, assign the function handle 
        %a value of zero    
        elseif botClosed && numBo == 2

            %Define the function handle to be a constant value of zero
            funcHandle = @(params,col,feTa,raTa,exTa,nS,nCo) 0;
            
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 1               
            
        %If the product-end has a Cv leading to the raffinate product tank
        elseif val1HasCv && ...           %valve 1 has a Cv
               
            
            flowDirColCurr == 0 && ... %co-current flow
               numBo == 1 && ...          %product-end boundary condition
               valRaTa(numStep) == 1      %to the raffinate product tank
                                    
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValOne2RaTa(params,col,feTa,raTa,exTa,nS,nCo);   
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        
        %If the product-end has a Cv leading to the raffinate waste stream
        elseif val1HasCv && ...           %valve 1 has a Cv
               flowDirColCurr == 0 && ... %co-current flow
               numBo == 1 && ...          %product-end boundary condition
               valRaTa(numStep) == 0      %to the raffinate waste stream
           
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValOne2RaWa(params,col,feTa,raTa,exTa,nS,nCo); 
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        %-----------------------------------------------------------------%     
        
        
           
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 2
        
        %If the feed-end has a Cv and the flow to the adsorber is from the
        %feed tank
        elseif val2HasCv && ...               %valve 2 has a Cv
               flowDirColCurr == 0 && ...     %co-current flow
               numBo == 2 && ...              %feed-end boundary condition
               valRinBot(numStep) == 0 && ... %not from the extract tank
               valPurBot(numStep) == 0        %not from the raffinate tank

            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeTa2Two(params,col,feTa,raTa,exTa,nS,nCo); 
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
           
        %If the feed-end has a Cv and the flow to the adsorber is from the
        %raffinate product tank
        elseif val2HasCv && ...           %valve 2 has a Cv
               flowDirColCurr == 0 && ... %co-current flow
               numBo == 2 && ...          %feed-end boundary condition
               valPurBot(numStep) == 1    %from the raffinate tank

            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaTa2Two(params,col,feTa,raTa,exTa,nS,nCo); 
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        
        %If the feed-end has a Cv and the flow to the adsorber is from the
        %raffinate product tank
        elseif val2HasCv && ...           %valve 2 has a Cv
               flowDirColCurr == 0 && ... %co-current flow
               numBo == 2 && ...          %feed-end boundary condition
               valRinBot(numStep) == 1    %from the extract tank

            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValExTa2Two(params,col,feTa,raTa,exTa,nS,nCo); 
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 3
        
        %If the product-end has a Cv and the flow to the adsorber is from 
        %the other interacting adsorber
        elseif val3HasCv && ...           %valve 3 has a Cv
               flowDirColCurr == 1 && ... %counter-current flow
               numBo == 1                 %product-end boundary condition
                         
           %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaEqCu(params,col,feTa,raTa,exTa,nS,nCo);  
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        
        %If the product-end is open and the flow to the adsorber is from 
        %the other interacting adsorber
        elseif val3Con == 1 && ...        %valve 3 is open
               flowDirColCurr == 1 && ... %counter-current flow
               numBo == 1                 %product-end boundary condition                           
                        
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaEqCu(params,col,feTa,raTa,exTa,nS,nCo);
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
                    
        %If the product-end has a Cv and the flow to the adsorber is to the 
        %other interacting adsorber
        elseif val3HasCv && ...           %valve 3 has a Cv
               flowDirColCurr == 0 && ... %co-current flow
               numBo == 1                 %product-end boundary condition                    
        
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaEqCo(params,col,feTa,raTa,exTa,nS,nCo); 
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
              
        %If the product-end is open and the flow to the adsorber is to the 
        %other interacting adsorber
        elseif val3Con == 1 && ...        %valve 3 is open
               flowDirColCurr == 0 && ... %co-current flow
               numBo == 1                 %product-end boundary condition 
           
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaEqCo(params,col,feTa,raTa,exTa,nS,nCo);
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 4
                
        %If the feed-end has a Cv and the flow to the adsorber is from 
        %the other interacting adsorber
        elseif val4HasCv && ...           %valve 4 has a Cv
               flowDirColCurr == 1 && ... %counter-current flow
               numBo == 2                 %feed-end boundary condition
            
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeEqCu(params,col,feTa,raTa,exTa,nS,nCo);
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = numBo;

        %If the feed-end has a Cv and the flow to the adsorber is from 
        %the other interacting adsorber
        elseif val4Con == 1 && ...        %valve 4 is open
               flowDirColCurr == 1 && ... %counter-current flow
               numBo == 2                 %feed-end boundary condition   
        
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeEqCu(params,col,feTa,raTa,exTa,nS,nCo);
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
  
        %If the feed-end has a Cv and the flow to the adsorber is to the 
        %other interacting adsorber
        elseif val4HasCv && ...           %valve 4 has a Cv
               flowDirColCurr == 0 && ... %co-current flow
               numBo == 2                 %feed-end boundary condition
            
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeEqCo(params,col,feTa,raTa,exTa,nS,nCo);
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;

        %If the feed-end has a Cv and the flow to the adsorber is to the 
        %other interacting adsorber
        elseif val4Con == 1 && ...        %valve 4 is open
               flowDirColCurr == 0 && ... %co-current flow
               numBo == 2                 %feed-end boundary condition   
           
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeEqCo(params,col,feTa,raTa,exTa,nS,nCo);  
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 5        
        
        %If the product-end has a Cv and the flow to the adsorber is from 
        %the extract product tank
        elseif val5HasCv && ...           %valve 5 has a Cv
               flowDirColCurr == 1 && ... %counter-current flow
               numBo == 1 && ...          %product-end boundary condition                        
               valRinTop(numStep) == 1    %rinse from the top end
               
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValExTa2Fiv(params,col,feTa,raTa,exTa,nS,nCo);
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        
        %If the product-end has a Cv and the flow to the adsorber is from 
        %the feed tank
        elseif val5HasCv && ...           %valve 5 has a Cv
               flowDirColCurr == 1 && ... %counter-current flow
               numBo == 1 && ...          %product-end boundary condition                                        
               valFeeTop(numStep) == 1    %feed from the top end

            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValFeTa2Fiv(params,col,feTa,raTa,exTa,nS,nCo);     
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
              
        %If the product-end has a Cv and the flow to the adsorber is from 
        %the raffinate product tank
        elseif val5HasCv && ...           %valve 5 has a Cv
               flowDirColCurr == 1 && ... %counter-current flow
               numBo == 1                 %product-end boundary condition                                        

            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValRaTa2Fiv(params,col,feTa,raTa,exTa,nS,nCo); 
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check for all the interaction modes involving valve 6
        
        %If the product-end has a Cv leading to the raffinate product tank
        elseif val6HasCv && ...           %valve 6 has a Cv
               flowDirColCurr == 1 && ... %counter-current flow
               numBo == 2 && ...          %feed-end boundary condition
               valExTa(numStep) == 1      %goes to the extract product tank
                                    
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValSix2ExTa(params,col,feTa,raTa,exTa,nS,nCo);
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        
        %If the product-end has a Cv leading to the raffinate product tank
        elseif val6HasCv && ...           %valve 6 has a Cv
               flowDirColCurr == 1 && ... %counter-current flow
               numBo == 2 && ...          %feed-end boundary condition
               valExTa(numStep) == 0      %goes to the extract waste stream 
                 
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValSix2ExWa(params,col,feTa,raTa,exTa,nS,nCo);
              
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Check for a discretized momentum balance with a constant boundary
        %condition with Cv specified at the product-end
        
        %The step is a constant pressure step, a step with momentum balance
        %equations, and has a Cv specified at the product-end
        elseif constPres == 0 && ... %Is a constant pressure step
               simMode == 1 && ... %Has a momentum balance
               val6Con == 1   && ... %Feed-end boundary condition is needed
               numBo == 2            %We will update the feed-end boundary
                                     %condition
        
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValSixConPrCu(params, ...
                                           col,feTa,raTa,exTa,nS,nCo);    
                                       
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        %-----------------------------------------------------------------%
        
                                     
                                     
        %-----------------------------------------------------------------%
        %Check for a discretized momentum balance with a constant boundary
        %condition with Cv specified at the feed-end
                                  
        %The step is a constant pressure step, a step with momentum balance
        %equations, and has a Cv specified at the product-end
        elseif constPres == 0 && ... %Is a constant pressure step
               simMode == 1 && ... %Has a momentum balance
               val1Con == 1   && ... %Product-end boundary condition is 
                                 ... %needed
               numBo == 1            %We will update the product-end 
                                     %boundary condition
        
            %Define the function handle
            funcHandle ...
                = @(params,col,feTa,raTa,exTa,nS,nCo) ...
                  calcVolFlowValOneConPrCo(params, ...
                                           col,feTa,raTa,exTa,nS,nCo);  
                                       
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = 0;
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %For all other cases, by default the valves must be completely
        %opened. Therefore, we assign a unity for the boundary condition
        %for the time being. 
        else
            
            %Check for momentum balance equation
            
            
            %We define an open boundary condition
            funcHandle = @(params,col,feTa,raTa,exTa,nS,nCo) 1;
            
            %Assign the flag denoting which boundary condition is specified
            flags.whichEnd = numBo;
            
            %List of Cases that do not require a boundary condition
            %
            %Case 1: If the product-end has an open valve leading to the
            %        raffinate product tank (i.e., valve 1) and we use a 
            %        constant pressure DAE model to simulate an adsorption 
            %        column. Also, we have a feed-end valve constant 
            %        specified. This is a co-current flow case.
            %Case 2: If the product-end has an open valve leading to the 
            %        raffinate product tank (i.e., valve 1) and we use
            %        discretized momentum balance equations to obtain the
            %        interior volumetric flow rates, while we have an
            %        expression or the control law that calculates the
            %        volumetric flow rate coming out from the product-end
            %        to maintain a constant pressure in the last CSTR. This
            %        is a co-current flow case.
            %Case 3: If there is an open valve between the feed tank and 
            %        the feed-end of the column (i.e., valve 2) and we use
            %        a constant pressure DAE model to simulate an
            %        adsorption column. Also, we have a product-end valve
            %        constant specified.
            %Case 4: If there is an open valve between the feed tank and
            %        the feed-end of the column (i.e., valve 2) and we use
            %        discretized momentum balance equations to obtain the
            %        interoir volumetric flow rates, while we have an
            %        expression or the control law that calculates the
            %        volumetric flow rate coming out from the feed-end to
            %        maintain a constrant pressure in the first CSTR. This
            %        is a counter-current case.
            %Case 5: If the product-end has an open valve leading to the 
            %        raffinate waste (i.e., valve 1), counter-current 
            %        rinse is going on at a high pressure, and we use a 
            %        constant pressure DAE model to simulate an adsorption 
            %        column. In this case, we have a specified valve 
            %        constant at the feed-end of the adsorption column.
            %Case 6: If the product-end has a linear valve with a specified 
            %        valve constant leading to the top-end of the 
            %        adsorption column from the raffinate product tank 
            %        (i.e., valve 5), counter-current rinse is going on at 
            %        a high pressure, and we use a constant pressure DAE 
            %        model to simulate an adsorption column. In this case, 
            %        we have a specified valve constant at the product-end 
            %        of the adsorption column.
            %Case 7: If the product-end has a linear valve with a specified 
            %        valve constant leading to the top-end of the 
            %        adsorption column from the raffinate product tank 
            %        (i.e., valve 5), counter-current rinse is going on at 
            %        a high pressure, and we use discretized momentum 
            %        balance equations to obtain the interior volumetric 
            %        flow rates and we have an expression or the control
            %        law to maintain the pressure in the 1st CSTR constant.
            %Case 8: If the product-end has a linear valve with a specified
            %        valve constant leading to the top-end of the adsorption
            %        column from the raffinate product tank,
            %        counter-current purge is going on at a low pressure,
            %        and we use a constant pressure DAE model to simulate
            %        the adsorber, we obtain the volumetric flow rate at
            %        the feed end as a result. 
            %Case 9: If the feed-end has a linear valve with a specified
            %        valve constant leading to the bottom-end of the 
            %        adsorption column from the raffinate product tank,
            %        co-current purge is going on at a low pressure,
            %        and we use a constant pressure DAE model to simulate
            %        the adsorber, we obtain the volumetric flow rate at
            %        the product end as a result. 
            %Case 10: If the product-end has a linear valve with a 
            %         specified valve constant leading to the top-end of 
            %         the adsorption column from the raffinate product 
            %         tank, counter-current purge is going on at a low 
            %         pressure, and we use discretized momentum balance
            %         equations to obtain the interior volumetric flow 
            %         rates, and have an expression for controlling the 
            %         volumetric flow rate in the 1st CSTR to maintain a
            %         constant pressure in the CSTR.
            %Case 11: If the feed-end has a linear valve with a specified 
            %         valve constant leading to the top-end of the 
            %         adsorption column from the raffinate product tank, 
            %         co-current purge is going on at a low pressure, and
            %         we use discretized momentum balance equations to 
            %         obtain the interior volumetric flow rates, and have 
            %         an expression for controlling the volumetric flow 
            %         rate in the last CSTR to maintain a constant pressure
            %         in the CSTR.
        
        end 
        %-----------------------------------------------------------------%
                                    
    %---------------------------------------------------------------------%
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%