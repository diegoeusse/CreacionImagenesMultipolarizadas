%=====Función para generar las componentes de esfuerzos en una placa de longitud infinita con agujero central sometida a carga de tracción==========
%====Referencia: Ecuaciones de Timoshenko presentadas en (Teoria de la elasticidad, 1968).

function [Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Placa(a,h,b,Fuerza,Resol)
P=Fuerza;
Factor=P/(b*h);% Relación para calcular los esfuerzos - Esfuerzo promedio de tracción aplicado
% a: Es el diametro del agujero [m].
% h: Es el espesor de la placa [m].
% b: Es el ancho de la placa [m]  "b" debe ser mayor al diametro "a" del
% agujero.
a=(a)/2;

%Es valido precisar que esta función genera un mapa de esfuerzos en un dominio cuadrado,
%Es decir, de dimensiones b(ancho) x b(ancho)

%======Plantillas
Img=zeros(Resol,Resol);%Plantilla circulo de agujero
Img2=zeros(Resol,Resol);%Plantilla circulo con radios
%Componentes polares
SigmaR=zeros(Resol,Resol);
SigmaT=zeros(Resol,Resol);
TauRT=zeros(Resol,Resol);
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
    Paso=b/(Resol-2);
for i=1:Resol-1
    X(1,i)=-b/2+(i-1)*Paso;
    Y(1,i)=b/2-(i-1)*Paso;
end
 else
  Paso=b/(Resol-1); % Caso de valor de resolución asignado como impar
for i=1:Resol
    X(1,i)=-b/2+(i-1)*Paso;
    Y(1,i)=b/2-(i-1)*Paso;
end
end

%Creando imagen plantilla según ejes del plano cartesiano
for i=1:Resol-1 %Este ciclo evalúa la coordenada Y - filas
   for j=1:Resol-1 %Este ciclo evalúa la coordenada X - Columnas
       if Y(1,i)^2+X(1,j)^2>=(a)^2%Condición para que este fuera del agujero
            Img(i,j)=255;
            Img2(i,j)=sqrt(Y(1,i)^2+X(1,j)^2);
       else
            Img(i,j)=0;
            Img2(i,j)=0;
       end
   end
end

%==Creando plano polar según imagen base
r=zeros(Resol,Resol);
theta=zeros(Resol,Resol);

%==Creando plano polar según posiciones X, Y
for i=1:Resol-1 %Este ciclo evalúa la coordenada Y - filas
   for j=1:Resol-1 %Este ciclo evalúa la coordenada X - Columnas
       r(i,j)=(X(1,j)^2+Y(1,i)^2)^(1/2);
    if Y(1,i)>0 && X(1,j)<=0
        theta(i,j)=acos(Y(1,i)/r(i,j));
    elseif Y(1,i)<=0 && X(1,j)<0
            theta(i,j)=pi/2+acos(abs(X(1,j))/r(i,j));
    elseif Y(1,i)<0 && X(1,j)>=0 
        theta(i,j)=pi+acos(abs(Y(1,i))/r(i,j));
    else
        theta(i,j)=2*pi-acos(Y(1,i)/r(i,j));
    end   
   end
end

%-------------------
%=== Calculando los mapas de esfuerzos en Coordenadas Polares
for i=1:Resol-1 %Este ciclo evalúa la coordenada Y - filas
        for j=1:Resol-1 %Este ciclo evalúa la coordenada X - Columnas
           
       if r(i,j)>a        
        SigmaR(i,j)=(Factor/2)*((1-a^2/(r(i,j)^2)+(1-4*(a^2/(r(i,j)^2))+3*(a^4/(r(i,j)^4)))*cos(2*theta(i,j))));
        SigmaT(i,j)=(Factor/2)*((1+a^2/(r(i,j))^2-(1+3*(a^4/(r(i,j)^4)))*cos(2*(theta(i,j)))));
        TauRT(i,j)=-(Factor/2)*(1+2*(a^2/(r(i,j)^2))-3*(a^4/(r(i,j))^4))*sin(2*theta(i,j));
        
        elseif r(i,j)==a
           SigmaR(i,j)=0;
           SigmaT(i,j)=Factor*(1-2*cos(2*theta(i,j)));
           TauRT(i,j)=0;
        else 
           SigmaR(i,j)=0;
           SigmaT(i,j)=0;
           TauRT(i,j)=0;
       end
        
           %Calculando los mapas de esfuerzos principales
           Sigma1(i,j)=0.5*(SigmaR(i,j)+SigmaT(i,j))+sqrt((0.5*(SigmaR(i,j)-SigmaT(i,j)))^2+TauRT(i,j)^2);
           Sigma2(i,j)=0.5*(SigmaR(i,j)+SigmaT(i,j))-sqrt((0.5*(SigmaR(i,j)-SigmaT(i,j)))^2+TauRT(i,j)^2);
           Isoclinico_Target(i,j)=-(1/2)*atan2((2*TauRT(i,j)),(SigmaR(i,j)-SigmaT(i,j)));  %Calculado entre -pi/2 y pi/2

           %=========
           %Diferencia de esfuerzos principales en coordenadas X e Y
           Diferencia(i,j)=Sigma1(i,j)-Sigma2(i,j); %Esperado
           
        end
end

% ===Extracción del contorno de la figura
Bordes=edge(Img>0);
Plantilla=Img;
Inconsistencia=(SigmaR-SigmaT)<0;
end