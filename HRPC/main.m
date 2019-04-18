clear

env = Environments(100000,293.15,'ChelaruM2'); % Pa % K % motorfile

%% State function initial condition and solution

n_oxv_0 = env.Motor.n_oxv; 
n_oxl_0 = env.Motor.n_oxl;
T_T_0 = env.Motor.T_T;
R_p_0 = env.Motor.R_p;
P_C_0 = env.P; %Pa
T_C_0 = env.T;
rho_C_0 = P_C_0/(287.058*T_C_0);
M_ox_C_0 = 0;
M_f_C_0 = 0;
M_a_C_0 = rho_C_0*(pi*R_p_0^2)*env.Motor.L_g;

state_0 = [n_oxv_0, n_oxl_0, T_T_0, R_p_0, P_C_0, T_C_0, rho_C_0, M_ox_C_0, M_f_C_0, M_a_C_0];
tspan = 0:0.05:30; % s

opts    = odeset('Events', @stopIntegrationEvent);
[t,state] = ode45(@(t,state) HRPC_function(t,state,env),tspan,state_0,opts);

% Derived Variables
P_T = 1e-5*(state(:,1) + env.Motor.n_spv) .* env.R_u .* state(:,3)./ (env.Motor.V_T - state(:,2).*env.Motor.V_mol_oxl(state(:,3))); % Tank Pressure [bars]

%%  Plot results 
figure(1)
subplot(2,3,1), plot(t(:),state(:,3),'k-v','MarkerFaceColor','k'), ... 
    title('Temperature vs. Time'),... 
    xlabel('Time [s]'),... 
    ylabel('Temperature [K]');
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'LineWidth'   , 1         , ...
        'FontName'   , 'Helvetica');
subplot(2,3,2), plot(t(:),state(:,1)*env.Motor.MW_ox,'k-^','MarkerFaceColor','k'),
                hold, plot(t(:),state(:,2)*env.Motor.MW_ox,'k-^'),hold off, ... 
    title('Mass of N2O vs. Time'),... 
    xlabel('Time [s]'),... 
    ylabel('Mass of N2O [kg]'),... 
    legend('kg of N2O gas','kg of N2O liquid');
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'LineWidth'   , 1         , ...
        'FontName'   , 'Helvetica');
subplot(2,3,3), plot(t(:),state(:,4),'k-o','MarkerFaceColor','k'), ... 
    title('Port Radius vs. Time'),... 
    xlabel('Time [s]'),... 
    ylabel('Radius [m]');
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'LineWidth'   , 1         , ...
        'FontName'   , 'Helvetica');
subplot(2,3,4), plot(t(:),state(:,5)/1e5,'k-s'),...
    hold, plot(t(:),P_T,'k-s','MarkerFaceColor','k'),hold off, ... 
    title('Pressure vs. Time'),... 
    xlabel('Time [s]'),... 
    ylabel('Pressure [Bars]');
    legend('Chamber Pressure', 'Oxidizer Tank Pressure');
     set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'LineWidth'   , 1         , ...
        'FontName'   , 'Helvetica');
subplot(2,3,5), plot(t(:),state(:,7),'k-o','MarkerFaceColor','k'),grid, ... 
    title('Chamber Gas Density vs. Time'),... 
    xlabel('Time [s]'),... 
    ylabel('Density [kg/m^3]');
     set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'LineWidth'   , 1         , ...
        'FontName'   , 'Helvetica');
subplot(2,3,6), plot(t(:),state(:,8),'k-o','MarkerFaceColor','k'), ...
    hold on, plot(t(:),state(:,9),'k-^','MarkerFaceColor','k'), ...
    plot(t(:),state(:,10),'k-s','MarkerFaceColor','k'),hold off, ... 
    title('Gas Accumulation vs. Time'),... 
    xlabel('Time [s]'),... 
    ylabel('Mass [kg]');
    legend('Oxidizer','Fuel','Air');
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'LineWidth'   , 1         , ...
        'FontName'   , 'Helvetica');
figure(2), plot(t(:),state(:,6),'k-s'), ... 
    title('Average Chamber Temperature vs. Time'),... 
    xlabel('Time [s]'),... 
    ylabel('Temperature [K]');
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'LineWidth'   , 1         , ...
        'FontName'   , 'Helvetica');
    
