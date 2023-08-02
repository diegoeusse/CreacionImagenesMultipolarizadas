function [Imagen_1,Imagen_2,Imagen_3,Imagen_4]=Imagen_Color_PolarCam(Diferencia,Angulo,Coeficiente,Espesor,Fuente,Camara,Correccion)
            
                Diff_T=Diferencia;
                [Filas,Columnas]=size(Diff_T);
                Espectro(1:371,1)=390:760;
                h=Espesor;
                Theta_T=Angulo;
                C=Coeficiente;
                Source=Fuente;
                Sensor=Camara;
                
                MRGB=Correccion;
            % Preparando datos espectrales
                r=zeros(371,1);
                g=zeros(371,1);
                b=zeros(371,1);
                r(:,1)=Sensor(1:371,1);%Respuesta en sensor r
                g(:,1)=Sensor(1:371,2);%Respuesta en sensor g
                b(:,1)=Sensor(1:371,3);%Respuesta en sensor b
   
            % Spectral interaction Camera-sensor
                Interaction_R=Source.*r;
                Interaction_G=Source.*g;
                Interaction_B=Source.*b;
                Interaction=zeros(371,3);
                Interaction(:,1)=Interaction_R;
                Interaction(:,2)=Interaction_G;
                Interaction(:,3)=Interaction_B;
                Interaction=Interaction/max(max(Interaction));

                
                
                % Iniciando matrices de imágenes según PST 6 Paterson 1998.
                Img_r_1=zeros(Filas,Columnas);
                Img_g_1=zeros(Filas,Columnas);
                Img_b_1=zeros(Filas,Columnas);

                Img_r_2=zeros(Filas,Columnas);
                Img_g_2=zeros(Filas,Columnas);
                Img_b_2=zeros(Filas,Columnas);

                Img_r_3=zeros(Filas,Columnas);
                Img_g_3=zeros(Filas,Columnas);
                Img_b_3=zeros(Filas,Columnas);

                Img_r_4=zeros(Filas,Columnas);
                Img_g_4=zeros(Filas,Columnas);
                Img_b_4=zeros(Filas,Columnas);

                for k=1:371
                    Phase=(2*pi*h*C*Diff_T)/(Espectro(k,1)*10^-9);
                    
                    Img_r_1=Img_r_1+(Interaction(k,1)/2)*(1+cos(Phase));
                    Img_g_1=Img_g_1+(Interaction(k,2)/2)*(1+cos(Phase));
                    Img_b_1=Img_b_1+(Interaction(k,3)/2)*(1+cos(Phase));
            
                    Img_r_2=Img_r_2+(Interaction(k,1)/2)*(1-cos(Phase));
                    Img_g_2=Img_g_2+(Interaction(k,2)/2)*(1-cos(Phase));
                    Img_b_2=Img_b_2+(Interaction(k,3)/2)*(1-cos(Phase));
            
                    Img_r_3=Img_r_3+(Interaction(k,1)/2)*(1-(sin(Phase).*cos(2*Theta_T)));
                    Img_g_3=Img_g_3+(Interaction(k,2)/2)*(1-(sin(Phase).*cos(2*Theta_T)));
                    Img_b_3=Img_b_3+(Interaction(k,3)/2)*(1-(sin(Phase).*cos(2*Theta_T)));
            
                    Img_r_4=Img_r_4+(Interaction(k,1)/2)*(1+(sin(Phase).*cos(2*Theta_T)));
                    Img_g_4=Img_g_4+(Interaction(k,2)/2)*(1+(sin(Phase).*cos(2*Theta_T)));
                    Img_b_4=Img_b_4+(Interaction(k,3)/2)*(1+(sin(Phase).*cos(2*Theta_T)));

                end            

            %Generando stack para normalización de sumatorias (Evida promediar por ell rango espectral)
            Stack=zeros(Filas,Columnas,12);
            Stack(:,:,1)=Img_r_1;
            Stack(:,:,2)=Img_g_1;
            Stack(:,:,3)=Img_b_1;
            Stack(:,:,4)=Img_r_2;
            Stack(:,:,5)=Img_g_2;
            Stack(:,:,6)=Img_b_2;
            Stack(:,:,7)=Img_r_3;
            Stack(:,:,8)=Img_g_3;
            Stack(:,:,9)=Img_b_3;
            Stack(:,:,10)=Img_r_4;
            Stack(:,:,11)=Img_g_4;
            Stack(:,:,12)=Img_b_4;


            Img_1=zeros(Filas,Columnas,3);
            Img_1(:,:,1)=Img_r_1;
            Img_1(:,:,2)=Img_g_1;
            Img_1(:,:,3)=Img_b_1;
            Img_1=Img_1/max2(Stack);
            
            Img_2=zeros(Filas,Columnas,3);
            Img_2(:,:,1)=Img_r_2;
            Img_2(:,:,2)=Img_g_2;
            Img_2(:,:,3)=Img_b_2;
            Img_2=Img_2/max2(Stack);
            
            Img_3=zeros(Filas,Columnas,3);
            Img_3(:,:,1)=Img_r_3;
            Img_3(:,:,2)=Img_g_3;
            Img_3(:,:,3)=Img_b_3;
            Img_3=Img_3/max2(Stack);
            
            Img_4=zeros(Filas,Columnas,3);
            Img_4(:,:,1)=Img_r_4;
            Img_4(:,:,2)=Img_g_4;
            Img_4(:,:,3)=Img_b_4;
            Img_4=Img_4/max2(Stack);
            
            % Corriegiendo intensidades según parámetros de pantalla (Matrices MRGB)
            I1RGB=zeros(3,1);
            I2RGB=zeros(3,1);
            I3RGB=zeros(3,1);
            I4RGB=zeros(3,1);

            for ii=1:Filas-1 %Este ciclo evalúa la coordenada Y - filas
                for j=1:Columnas-1 %Este ciclo evalúa la coordenada X - Columnas
                    I1RGB(1:3,1)=Img_1(ii,j,1:3);
                    RGB1=MRGB*I1RGB;
                                       
                    I2RGB(1:3,1)=Img_2(ii,j,1:3);
                    RGB2=MRGB*I2RGB;                    
                    
                    I3RGB(1:3,1)=Img_3(ii,j,1:3);
                    RGB3=MRGB*I3RGB;                    
                    
                    I4RGB(1:3,1)=Img_4(ii,j,1:3);
                    RGB4=MRGB*I4RGB;                    
                   
                    % Ajusto valores fuera de rango
                    for Q=1:3
                        if RGB1(Q,1)>1
                            Img_1(ii,j,Q)=1;
                        else
                                if RGB1(Q,1)>=0
                                    Img_1(ii,j,Q)=RGB1(Q,1);
                                else
                                    Img_1(ii,j,Q)=0;
                                end
                        end
                        
                        if RGB2(Q,1)>1
                            Img_2(ii,j,Q)=1;
                        else
                                if RGB2(Q,1)>=0
                                    Img_2(ii,j,Q)=RGB2(Q,1);
                                else
                                    Img_2(ii,j,Q)=0;
                                end
                        end
                        
                        if RGB3(Q,1)>1
                            Img_3(ii,j,Q)=1;
                        else
                                if RGB3(Q,1)>=0
                                    Img_3(ii,j,Q)=RGB3(Q,1);
                                else
                                    Img_3(ii,j,Q)=0;
                                end
                        end
                        
                        if RGB4(Q,1)>1
                            Img_4(ii,j,Q)=1;
                        else
                                if RGB4(Q,1)>=0
                                    Img_4(ii,j,Q)=RGB4(Q,1);
                                else
                                    Img_4(ii,j,Q)=0;
                                end
                        end
        
                    end
                    
                end
            end
            %Escalo a 255 niveles de gris
            Img_1=Img_1*255;
            Imagen_1=Img_1;
            Img_2=Img_2*255;
            Imagen_4=Img_2;
            Img_3=Img_3*255;
            Imagen_3=Img_3;
            Img_4=Img_4*255;
            Imagen_2=Img_4;

end