%***********************************************************************************
%Juan Carlos Briñez de León.
%Departamento de Ingeniería electrónica.
%Institución Universitaria Pascual Bravo.
%==
%Generando imágenes para cámara polarizada
%***********************************************************************************
close all
clc

% 1. Generación de curva de carga

    % Listas de variaciones
        
        % Valores constantes
        Frames=10; % Cantidad de cuadros en la secuencia.
        Resolucion=256; % Vale para filas y columnas por ser matríz cuadrada
        Espesor=0.01; %10mm
        Pantalla='No_corrección';
        Coeficiente=3.5*10^-12; %%Coeficiente óptico pmma
        
        % Valores a iterar
        Cargas = [3000000];
        Modelos = ["Muesca"];
        Nombres_Fuentes = ["LCD", "Fluorescente", "Concord", "DL11", "RXD2", "Philips", "Sylvania", "Toshiba", "Willard"];
        Nombres_Sensores = ["IMX250MYR","IMX250MZR"];
        N_Fuentes = [12, 3, 4, 5, 6, 8, 9, 10, 11];
        N_Sensores = [1, 2];

        % Cargando datos espectrales de fuente y pantalla
        % - Light sources
        load('Parametros\Iluminación\Sources_Botero.mat');%Respuesta espectral del dispositivo
            %Sources(:,1)  => Source_0 = Ideal
            %Sources(:,2)  => Source_1 = Incandescente
            %Sources(:,3)  => Source_2 = Fluorescente
            %Sources(:,4)  => Source_3 = Concord_Beacon_Muse_2052867_(Narrow)_LED_3000K_90_CRI
            %Sources(:,5)  => Source_4 = Cooper_DL11_WS_WW_LED
            %Sources(:,6)  => Source_5 = Cooper_RXD2_RWS_WW_LED
            %Sources(:,7)  => Source_6 = Philips_50W_MR16_TH_2703K_99_CRI
            %Sources(:,8)  => Source_7 = Philips_EnduraLED_MR16_LED_3000K_82_CRI
            %Sources(:,9)  => Source_8 = Sylvania_UltraLED_Par_30LN_40_LED_3000K_87_CRI
            %Sources(:,10) => Source_9 = Toshiba_ECore_Par30s_23Deg_LED_6500K_65_CRI
            %Sources(:,11) => Source_10 = Willard_LEDGO_CN_600SC_LED
            %Sources(:,12) => Source_11 = Absoluto de pantalla LCD

        % - Camera sensors
        % load('Parametros\Cámaras\Sensores_Hermes.mat');%Respuesta espectral del dispositivo
            %Sensores(:,:,1)  => Sensor_0.mat:    Ojo Humano
            %Sensores(:,:,2)  => Sensor_1.mat:    Cámara=DCC1240C           Sensor=e2v-EV76C560ACT
            %Sensores(:,:,3)  => Sensor_2.mat:    Cámara=DCC1645C           Sensor=Aptina-MT9M131
            %Sensores(:,:,4)  => Sensor_3.mat:    Cámara=DCC3260C           Sensor=Sony-IMX249LQJ-C
            %Sensores(:,:,5)  => Sensor_4.mat:    Cámara=exo304CU3          Sensor=Sony-IMX304LQR
            %Sensores(:,:,6)  => Sensor_5.mat:    Cámara=hr25CCL            Sensor=ON Semiconductor NOIP1SE025KA-GDI
            %Sensores(:,:,7)  => Sensor_6.mat:    Cámara= hr16050CFLCPC     Sensor=ON Semiconductor KAI-16050-C
            %Sensores(:,:,8)  => Sensor_7.mat:    Cámara=IDS-UI-3590CP      Sensor=AR1820HSSC00SHEA0
            %Sensores(:,:,9)  => Sensor_8.mat:    Cámara=PL-D755CU          Sensor=Sony IMX250
            %Sensores(:,:,10) => Sensor_9.mat:    Cámara=Manta G-223        Sensor=Allied Vision  CMOSIS/ams CMV2000
            %Sensores(:,:,11) => Sensor_10.mat:   Cámara=Manta G-507        Sensor=Sony IMX264

        % - Camera sensors polarizados
        load('Parametros\Cámaras\Sensores_Eusse.mat'); %Respuesta espectral del dispositivo
            %Sensores(:,:,1)  => Sensor_0.mat:    Sensor=IMX250MYR
            %Sensores(:,:,2)  => Sensor_1.mat:    Sensor=IMX250MZR
            %Sensores(:,:,3)  => Sensor_2.mat:    Sensor=IMX253MZR

           
        % Página oficial de  http://brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
            load(['Parametros\Matrices_Correccion','\','MRGB0.mat']);
            %MRGB0=No corrección
            %MRGB1=Adobe 65
            %MRGB2=Apple RGB
            %MRGB3=Best RGB
            %MRGB4=Beta RGB
            %MRGB5=CIE RGB
            %MRGB6=Don RGB 4
            %MRGB7=ColorMatch RGB
            %MRGB8=ProPhoto RGB
            %MRGB9=sRGB
            %MRGB10=Wide Gamut RGB
            
            Correccion=MRGB;
        
        for i=1
            Carga_max=Cargas(i); %Valor de la carga máxima aplicada en Newton. (Cambia según la geometría)
             % Defining stress curve
            [Curva_Fuerza,Curva]=Lineal(Frames,Carga_max);% Curvas disponibles:Lineal,Exponencial,Logaritmica,Coseno,Cos_Exp,Cos_Log

            % Preparando carpetas de almacenamiento

            %%**Para modelos
            Modelo = Modelos(i);

            Carpeta=['Coleccion','\',convertStringsToChars(Modelo),'__','Carga','_',Curva,'_',int2str(Carga_max),'N','__',int2str(Frames),'_','frames','__',int2str(Resolucion),'_','Resolución'];%Nombre de la carpeta
            mkdir(Carpeta);
            
            %Para mapas de esfuerzos
            mkdir([Carpeta,'\','Angulo']);
            mkdir([Carpeta,'\','Diferencia']);
            mkdir([Carpeta,'\','Phase']);
            mkdir([Carpeta,'\','Sigma_1']);
            mkdir([Carpeta,'\','Sigma_2']);
            
            for j = 1:9
                %%**Para fuentes de iluminacion
                Fuente = Nombres_Fuentes(j);

                for k = 1:2
                    %%**Para sensores de camara
                    Camara = Nombres_Sensores(k);  
                    
                    %Para imágenes                       
                    mkdir([Carpeta,'\','Imágenes','\',convertStringsToChars(Fuente),'_',convertStringsToChars(Camara),'_',Pantalla,'\','Img_1']); % 90°
                    mkdir([Carpeta,'\','Imágenes','\',convertStringsToChars(Fuente),'_',convertStringsToChars(Camara),'_',Pantalla,'\','Img_2']); % 45°
                    mkdir([Carpeta,'\','Imágenes','\',convertStringsToChars(Fuente),'_',convertStringsToChars(Camara),'_',Pantalla,'\','Img_3']); % 135°
                    mkdir([Carpeta,'\','Imágenes','\',convertStringsToChars(Fuente),'_',convertStringsToChars(Camara),'_',Pantalla,'\','Img_4']); % 0°

                    for l = 1:Frames
                        Fuerza=Curva_Fuerza(1,l);
                        % Generando mapas de esfuerzos según modelos analíticos

                        %if i == 1
                            % A- Disco a compresión
                            %Radio=0.05; % Disco de 50mm de radio
                            %[Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Disco(Radio,Espesor,Fuerza,Resolucion);
                        
                        %elseif i == 2
                            % B- Anillo a compresión
                            %Radio_Int=0.025;Radio_Ext=0.05;Contacto=3;% Radio interno, radio externo y ángulo de contacto
                            %[Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Anillo(Radio_Ext,Radio_Int,Espesor,Fuerza,Contacto,Resolucion);

                        %elseif i == 3
                            % C- Placa
                            %Altura=0.01;Base=0.05;% Medidas en metros
                            %[Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Placa(Altura,Espesor,Base,Fuerza*2,Resolucion);

                        %elseif i == 4
                            % D- Viga voladizo puntual
                            %Alto=50;Ancho=200; 
                            %[Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Viga_Vola_Puntual(Alto,Ancho,Fuerza*50,Resolucion);
                            
                        %else
                            % E-Viga voladizo distribuida
                            %Largo=50;Ancho=200;
                            %[Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Viga_Vola_Distr(Largo,Ancho,Fuerza*300,Resolucion);
                          
                            % G-Estructura vertical
                            %Largo=2000; Ancho=500;
                            %[Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Estructura_Vertical(Largo,Ancho,Fuerza*300,Resolucion);

                            % H-Ménsula
                            %Radio_Int=0.025;Radio_Ext=0.05; % Radio interno, radio externo
                            %[Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Mensula(Radio_Ext,Radio_Int,Fuerza,Resolucion);
  
                            % I-Muesca
                            Ancho = 0.0127; Profundidad_Muesca = 0.00635; Ajuste = 0.92; Esfuerzo_aplicado = Fuerza; %[MPa];
                            [Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Muesca(Ancho, Profundidad_Muesca, Ajuste, Esfuerzo_aplicado, Resolucion);

                        % Seleccionando una fuente de iluminación y una cámara
                        f_num = N_Fuentes(j);
                        s_num = N_Sensores(k);
                        Source=Sources(:,f_num); 
                        Sensor=Sensores(:,:,s_num);
                        
                        [Img_1,Img_2,Img_3,Img_4]=Imagen_Color_PolarCam(Diferencia,Isoclinico_Target,Coeficiente,Espesor,Source,Sensor,Correccion);
           
                        %Marcando el borde de los modelos
                        Edge=zeros(Resolucion,Resolucion,3);
                        Edge(:,:,1)=-Bordes+1;
                        Edge(:,:,2)=-Bordes+1;
                        Edge(:,:,3)=-Bordes+1;
                        Img_1=Img_1.*Edge;% Superpone borde negro
                        Img_2=Img_2+(-Edge+1)*200;% Superpone borde blanco
                        Img_3=Img_3.*Edge;% Superpone borde negro
                        Img_4=Img_4.*Edge;% Superpone borde negro
      
                        % Saving images
                        Name_Input=([Carpeta,'\','Imágenes','\',convertStringsToChars(Fuente),'_',convertStringsToChars(Camara),'_',Pantalla,'\','Img_1','\','Img1_',int2str(l),'.bmp']);
                        imwrite(uint8(Img_1),Name_Input);
        
                        Name_Input=([Carpeta,'\','Imágenes','\',convertStringsToChars(Fuente),'_',convertStringsToChars(Camara),'_',Pantalla,'\','Img_2','\','Img2_',int2str(l),'.bmp']);
                        imwrite(uint8(Img_2),Name_Input);
        
                        Name_Input=([Carpeta,'\','Imágenes','\',convertStringsToChars(Fuente),'_',convertStringsToChars(Camara),'_',Pantalla,'\','Img_3','\','Img3_',int2str(l),'.bmp']);
                        imwrite(uint8(Img_3),Name_Input);
        
                        Name_Input=([Carpeta,'\','Imágenes','\',convertStringsToChars(Fuente),'_',convertStringsToChars(Camara),'_',Pantalla,'\','Img_4','\','Img4_',int2str(l),'.bmp']);
                        imwrite(uint8(Img_4),Name_Input);
        
                        % Guardando mapas de esfuerzos
                        Dif_T=Diferencia;
                        Theta_T=Isoclinico_Target;
                              
                        save([Carpeta,'\','Angulo','\','Theta_T','_',int2str(l),'.mat'],'Theta_T');
                        save([Carpeta,'\','Diferencia','\','Dif','_',int2str(l),'.mat'],'Dif_T');
                        save([Carpeta,'\','Sigma_1','\','Sigma1','_',int2str(l),'.mat'],'Sigma1');
                        save([Carpeta,'\','Sigma_2','\','Sigma2','_',int2str(l),'.mat'],'Sigma2');
                        
                        % Guardando mapa de fase
                        Phase_T=(2*pi*Espesor*Coeficiente*Dif_T)/(576.5541*10^-9); %En un puntoo espectral medio
                        save([Carpeta,'\','Phase','\','Phase_T','_',int2str(l),'.mat'],'Phase_T'); 
                        
                        % Guardando Adicionales
                        save([Carpeta,'\','Plantilla.mat'],'Plantilla');
                        save([Carpeta,'\','Bordes.mat'],'Bordes');
                        save([Carpeta,'\','Inconsistencia.mat'],'Inconsistencia');
                        
                        save([Carpeta,'\','Curva_Fuerza.mat'],'Curva_Fuerza');
                        
                        save([Carpeta,'\','Imágenes','\',convertStringsToChars(Fuente),'_',convertStringsToChars(Camara),'_',Pantalla,'\','Curva_Sensor.mat'],'Sensor');
                        save([Carpeta,'\','Imágenes','\',convertStringsToChars(Fuente),'_',convertStringsToChars(Camara),'_',Pantalla,'\','Curva_Fuente.mat'],'Source');
                    end

                end

            end        

        end             