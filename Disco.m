%=====Función para generar las componentes de esfuerzos en un anillo bajo compresión diametral ==========
%====Referencia: Ecuaciones de Timoshenko presentadas en (New Numerical Method for the Photoelasticity technique: Pedro Americo 2012).

function [Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Disco(R,h,Fuerza,Resol)
P=Fuerza;
Factor=(2*P)/(pi*h);%Relación para calcular los esfuerzos
D=2*R;
%======Plantillas
Img=zeros(Resol,Resol);%Plantilla circulo
Img2=zeros(Resol,Resol);%Plantilla circulo con radios
%Componentes rectángulares
SigmaX=zeros(Resol,Resol);
SigmaY=zeros(Resol,Resol);
TauXY=zeros(Resol,Resol);
%Componentes principales
Sigma1=zeros(Resol,Resol);
Sigma2=zeros(Resol,Resol);
Isoclinico_Target=zeros(Resol,Resol);
%Diferencia de esfuerzos principales
Diferencia=zeros(Resol,Resol);

%==Creando plano cartersiano según imagen base
X=zeros(1,Resol);
Y=zeros(1,Resol);
    %Crea los ejes del plano, ajustando para tener origen (0,0)
if mod(Resol,2)==0 % Caso de valor de resolución asignado como par
    Paso=2*R/(Resol-2);
    for i=1:Resol-1
        X(1,i)=-R+(i-1)*Paso;
        Y(1,i)=-R+(i-1)*Paso;
    end
else
    Paso=2*R/(Resol-1); % Caso de valor de resolución asignado como impar
    for i=1:Resol
        X(1,i)=-R+(i-1)*Paso;
        Y(1,i)=-R+(i-1)*Paso;
    end
end

%Creando imagen plantilla según ejes del plano cartesiano
for i=1:Resol-1 %Este ciclo evalúa la coordenada Y - filas
   for j=1:Resol-1 %Este ciclo evalúa la coordenada X - Columnas
       if Y(1,i)^2+X(1,j)^2<=R^2%Condición para que sea disco
            Img(i,j)=255;
            Img2(i,j)=sqrt(Y(1,i)^2+X(1,j)^2);
       else
            Img(i,j)=0;
            Img2(i,j)=0;
       end
   end
end

%-------------------
%=== Calculando los mapas de esfuerzos en coordenadas Rectángulares 
for i=1:Resol-1 %Este ciclo evalúa la coordenada Y - filas
   for j=1:Resol-1 %Este ciclo evalúa la coordenada X - Columnas
       if Y(1,i)^2+X(1,j)^2<=R^2%Condición para que sea disco
           x=X(1,j);
           y=Y(1,i);
           r1=sqrt((x^2)+(R-y)^2);
           r2=sqrt((x^2)+(R+y)^2);
           %Para corregir los esfuerzos en los puntos de contacto
           if r1==0
              r1=1;
           end
           if r2==0
              r2=1;
           end
           %=========
           SigmaX(i,j)=-Factor*((((R-y)*x^2)/(r1^4))+(((R+y)*x^2)/(r2^4))-(1/D));
           SigmaY(i,j)=-Factor*((((R-y)^3)/(r1^4))+(((R+y)^3)/(r2^4))-(1/D));
           TauXY(i,j)=Factor*(((((R-y)^2)*x)/(r1^4))-((((R+y)^2)*x)/(r2^4)));
           
           %Calculando los mapas de esfuerzos principales
           Sigma1(i,j)=((SigmaX(i,j)+SigmaY(i,j))/2)+sqrt((((SigmaX(i,j)-SigmaY(i,j))/2)^2)+(TauXY(i,j))^2);
           Sigma2(i,j)=((SigmaX(i,j)+SigmaY(i,j))/2)-sqrt((((SigmaX(i,j)-SigmaY(i,j))/2)^2)+(TauXY(i,j))^2);
           Isoclinico_Target(i,j)=-(1/2)*atan2((2*TauXY(i,j)),(SigmaX(i,j)-SigmaY(i,j)));%Calculado entre -pi/2 y pi/2

           %=========
           %Diferencia de esfuerzos principales en coordenadas X e Y
           Diferencia(i,j)=Sigma1(i,j)-Sigma2(i,j); %Esperado
           
           %Para corregir los esfuerzos en los puntos de contacto
           if x==0 && y==R
              Diferencia(i,j)=0; %Según Ramesh
           end
           if x==0 && y==-R
              Diferencia(i,j)=0; %Según Ramesh
           end
           %=========
       else
            SigmaX(i,j)=0;
            SigmaY(i,j)=0;
            TauXY(i,j)=0;
            Diferencia(i,j)=0;
       end
   end
end

% ===Extracción del contorno de la figura
Bordes=edge(Img>0);
Plantilla=Img;
Inconsistencia=(SigmaX-SigmaY)<0;
end