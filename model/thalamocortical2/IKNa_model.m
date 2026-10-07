nai = 0:0.1:100;
w_infCx3 = 1./(1 + (38.7./nai).^3.5);
w_infNRT1 = 1./(1 + (7.3./nai).^4.6);
w_infNRT2 = 1./(1 + (50./nai).^2.5);
w_infNRT3 = 1./(1 + (30./nai).^5);


figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(nai, w_infCx3);
hold on
plot(nai, w_infNRT1);
plot(nai, w_infNRT2);
plot(nai, w_infNRT3);
legend('w_{infCx3}','w_{infNRT1}','w_{infNRT2}','w_{infNRT3}')

%p = 1./(1 + ((50 + 0)./nai).^2.5);
%p = 1./(1 + (nai./(50 + 0)).^5);
%plot(nai, p, 'r');
hold off