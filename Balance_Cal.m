%%%天平矩阵程序，不能更改！！！%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%如有bug，在github上找到LSL_ASAP项目发issue或者联系贾树杰%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [Y, Mz, X, Mx, Z, My] = Balance_Cal(balance_voltage, bridge_voltage)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %说明
    %2N小量程天平电压转换
    %输入按照 Y Mz X Mx Z My 排列
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %天平矩阵
    %         Y          Mx         Z    Mz          X          My
    Matrix = [0.5536636	 0.0531595	0	 0.0637731	 0.5562558	0          %deltaU
              0         -6.26E-06	0	-1.61E-05	-0.006445	0.00E+00   %Y
             -0.009198	 0	        0	 0.0005985	-0.040805	0          %Mx
              0	         0	        0	 0           0	        0          %Z
              0.0821301	-0.000578	0	 0	        -0.033633	0          %Mz
              0.0122153	 1.37E-05	0	 5.80E-05	 0	        0.00E+00   %X
              0	         0	        0	 0	         0	        0          %My
              0	         4.58E-06	0	 6.12E-06	 9.92E-06	0.00E+00   %Y(Y+2Gy)
              0	         0	        0	 0	         0	        0          %(Y+Gy)Mx
              0	         0.00E+00	0	 0.00E+00	 0	        0.00E+00   %(Y+Gy)Z
              0	         0	        0	 0	         0	        0          %(Y+Gy)Mz
              0	         0.00E+00	0	 0.00E+00	 0	        0.00E+00   %(Y+Gy)X
              0	         0	        0	 0	         0	        0          %(Y+Gy)My
              0.0068252	 0.00E+00	0	-5.76E-04	 0.0311408	0.00E+00   %MxMx
              0	         0	        0	 0	         0	        0          %MxZ
              0	         0.00E+00	0	 0.00E+00	 0	        0.00E+00   %MzMx
              0	         0	        0	 0	         0	        0          %Mx(X+Gx)
              0	         0.00E+00	0	 0.00E+00	 0	        0.00E+00   %MxMy
              0	         0	        0	 0	         0	        0          %ZZ
              0	         0.00E+00	0	 0.00E+00	 0	        0.00E+00   %ZMz
              0          0	        0	 0	         0	        0          %Z(X+Gx)
              0          0.00E+00	0	 0.00E+00	 0	        0.00E+00   %ZMy
              0.0042168	 0.0006971	0	 0	        -0.003529	0          %MzMz
              0          0.00E+00	0	 0.00E+00	 0	        0.00E+00   %Mz(X+Gx)
              0          0	        0	 0	         0	        0          %MzMy
              0.0001276  1.12E-05	0	-8.49E-08	 0	        0.00E+00   %X(X+2Gx)
              0          0	        0	 0	         0	        0          %(X+Gx)My
              0          0.00E+00	0	 0.00E+00	 0	        0.00E+00]; %MyMy
    %重力修正
    Gy = 0; Gx = 0;%天平沿着Z轴安装
    %电压修正
    K_check = 1.0149; U_check = 10.0073;
    K = U_check / bridge_voltage * K_check;

    %数据重新排列
    %测量分量排序为Y Mz X Mx Z My;天平矩阵排序为Y Mx Z Mz X My
    balance_voltage([1, 2, 3, 4, 5, 6]) = balance_voltage([1, 4, 5, 2, 3, 6]);
    
    %计算
    DU = balance_voltage * K;
    F = DU .* Matrix(1, :);
    C = zeros(1, 27);
    main_Y = F(1);
    main_Mx = F(2);
    main_Z = F(3);
    main_Mz = F(4);
    main_X = F(5);
    main_My = F(6);

    for i = 1 : 10
        if i == 1
            Y = main_Y;
            Mx = main_Mx;
            Z = main_Z;
            Mz = main_Mz;
            X = main_X;
            My = main_My;
        else
            Y = main_Y + C * Matrix(2 : end, 1);
            Mx = main_Mx + C * Matrix(2 : end, 2);
            %Z = main_Z + C * Matrix(2 : end, 3);
            Mz = main_Mz + C * Matrix(2 : end, 4);
            X = main_X + C * Matrix(2 : end, 5);
            %My = main_My + C * Matrix(2 : end, 6);
        end
        C(1) = Y;
        C(2) = Mx;
        %C(3) = Z;
        C(4) = Mz;
        C(5) = X;
        %C(6) = My;
        C(7) = Y * (Y + 2 * Gy);
        %C(8) = (Y + Gy) * Mx;
        %C(9) = (Y + Gy) * Z;
        %C(10) = (Y + Gy) * Mz;
        %C(11) = (Y + Gy) * X;
        %C(12) = (Y + Gy) * My;
        C(13) = Mx * Mx;
        %C(14) = Mx * Z;
        %C(15) = Mz * Mx;
        %C(16) = Mx * (X + Gx);
        %C(17) = Mx * My;
        %C(18) = Z * Z;
        %C(19) = Z * Mz;
        %C(20) = Z * (X + Gx);
        %C(21) = Z * My;
        C(22) = Mz * Mz;
        %C(23) = Mz * (X + Gx);
        %C(24) = Mz * My;
        C(25) = X * (X + 2 * Gx);
        %C(26) = (X + Gx) * My;
        %C(27) = My * My;
    end
end