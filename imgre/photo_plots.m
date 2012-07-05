load thor2;

plot(time1./1e-9, (voltage1 - mean(voltage1))./435./(1.2569e-4),'b');
hold on;
plot(time3./1e-9, (voltage3 - mean(voltage3))./435.*4000,'r:');
axis([0 1900 -50 50]);
xlabel('time [ns]');
ylabel('power [W]');
legend('photodetector output','DM output (arb. amplitude)');
title('Laser power of OSRAM SPL PL90\_3 measured with Thorlabs PDA36A');

%%
load thor3;

figure;
plot(time1./1e-9, (voltage1 - mean(voltage1))./382.5./(1*10^-2.4),'b');
hold on;
plot(time3./1e-9, (voltage3 - mean(voltage3))./441.*10,'r:');
axis([0 1900 -0.2 0.2]);
xlabel('time [ns]');
ylabel('power [W]');
legend('photodetector output','DM output (arb. amplitude)');
title('Laser power of Apollo module measured with Thorlabs PDA36A');

%%
load newport2

figure;
plot(time1./1e-9, (voltage1 - mean(voltage1))./441./(1e-2),'b');
hold on;
plot(time3./1e-9, (voltage3 - mean(voltage3))./441.*10,'r:');
axis([0 1900 -0.2 0.2]);
xlabel('time [ns]');
ylabel('power [W]');
legend('photodetector output','DM output (arb. amplitude)');
title('Laser power of Apollo module measured with Newport 818-BB-21A');