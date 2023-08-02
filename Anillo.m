%=====Función para generar las componentes de esfuerzos en un anillo bajo compresión diametral ==========
%====Referencia: Tokovyy, Y. V., Hung, K. M., & Ma, C. C. (2010). Determination of stresses and displacements in a thin annular disk subjected to diametral compression. Journal of Mathematical Sciences, 165(3), 342-354.

function [Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Anillo(R2,R1,h,Fuerza,Contacto,Resol)
Contacto=Contacto*pi/180;%Ángulo de contacto para aplicación de fuerza (Transformación a 'Pi radianes')
P=(Fuerza)/(h*2*Contacto*R2);
%2- creando plantilla del anillo
Plantilla=zeros(Resol,Resol);%Plantilla circulo
Plantilla_radio=zeros(Resol,Resol);%Plantilla circulo con radios
Plantilla_angulo=zeros(Resol,Resol);%Plantilla circulo con ángulo
%==Creando plano cartersiano según imagen base
X=zeros(1,Resol);
Y=zeros(1,Resol);
    %Crea los ejes del plano, ajustando para tener origen (0,0)
if mod(Resol,2)==0 % Caso de valor de resolución asignado como par
    Paso=2*R2/(Resol-2);
    for i=1:Resol-1
        X(1,i)=-R2+(i-1)*Paso;%Coordenada X. control de columnas
        Y(1,i)=-R2+(i-1)*Paso;%Coordenada Y. control de filas
    end
else
    Paso=2*R2/(Resol-1); % Caso de valor de resolución asignado como impar
    for i=1:Resol
        X(1,i)=-R2+(i-1)*Paso;
        Y(1,i)=-R2+(i-1)*Paso;
    end
end

%Creando imagen plantilla a partir de valores del plano cartesiano
for i=1:Resol-1 %Este ciclo evalúa la coordenada Y - filas
   for j=1:Resol-1 %Este ciclo evalúa la coordenada X - Columnas
       if Y(1,i)^2+X(1,j)^2<=R2^2 && Y(1,i)^2+X(1,j)^2>R1^2%Condición para que sea disco
            Plantilla(i,j)=255;
            Plantilla_radio(i,j)=sqrt(Y(1,i)^2+X(1,j)^2);
            Plantilla_angulo(i,j)=(atan(X(1,j)/Y(1,i)))+pi/2;% Es Y/X porque el ángulo que se busca es horizontal
           
       else
            Plantilla(i,j)=0;
            Plantilla_radio(i,j)=0;
            Plantilla_angulo(i,j)=0;
       end
   end
end

%3- creando Mapas de esfuerzos según plantillas base
%Variables
%Componentes polares del esfuerzo
SigmaR=zeros(Resol,Resol);
SigmaT=zeros(Resol,Resol);
TauRT=zeros(Resol,Resol);
%Componentees principales del esfuerzo
Sigma1=zeros(Resol,Resol);
Sigma2=zeros(Resol,Resol);
Isoclinico_Target=zeros(Resol,Resol);
%Componentees rectángulares de esfuerzo
SigmaX=zeros(Resol,Resol);
SigmaY=zeros(Resol,Resol);
%Diferencia de esfuerzos principales
Diferencia=zeros(Resol,Resol);

%Operaciones iniciales
K=R1/R2; %Factor radial
Factor=P/(pi);%relación para calcular los esfuerzos

for i=1:Resol-1 %Este ciclo evalúa la coordenada Y - filas
   for j=1:Resol-1 %Este ciclo evalúa la coordenada X - Columnas
       Ro= Plantilla_radio(i,j)/R2;%Porcentaje de radio evaluado
       T=Plantilla_angulo(i,j);
    if Plantilla_radio(i,j)<=R2 && Plantilla_radio(i,j)>=R1 %Condición para evaluar sólo la ROI
           SummatoryR=0;
           SummatoryT=0;
           SummatoryCort=0;
           
           for m=1:1:100%Calcula los valores incrementales de las fórmula
               Am=(((K^(2*(m+1)))*(K^(2*m)-K^(-2*m)))-((2*m)*(1-K^2)))/((4*(m^2))*((1-K^2)^2)-(K^2)*((K^(2*m)-K^(-2*m))^2));
               Bm=(((2*m)*(1-K^2))-((K^(2*(1-m)))*(K^(2*m)-K^(-2*m))))/((4*(m^2))*((1-K^2)^2)-(K^2)*((K^(2*m)-K^(-2*m))^2));
               
               Rm=(((2*(m+1)*(Ro^(-2*m)))-((2*m+1)*(K^2)*(Ro^(-2*(m+1))))-((K^(2*(1-2*m)))*(Ro^(-2*(1-m)))))*Am)-(((2*(m-1)*Ro^(2*m))-((2*m-1)*(K^2)*(Ro^(-2*(1-m))))+((K^(2*(1+2*m)))*(Ro^(-2*(1+m)))))*Bm);
               FIm=((((2*m+1)*(K^2)*(Ro^(-2*(m+1))))-(2*(m-1)*Ro^(-2*m))+((K^(2*(1-2*m)))*(Ro^(-2*(1-m)))))*Am)-((((2*m-1)*(K^2)*(Ro^(-2*(1-m))))-(2*(m+1)*Ro^(2*m))-((K^(2*(1+2*m)))*(Ro^(-2*(1+m)))))*Bm);
               Sm=(((2*m*(Ro^(-2*m)))-((2*m+1)*(K^2)*(Ro^(-2*(m+1))))+((K^(2*(1-2*m)))*(Ro^(-2*(1-m)))))*Am)+(((2*m*(Ro^(2*m)))-((2*m-1)*(K^2)*(Ro^(-2*(1-m))))-((K^(2*(1+2*m)))*(Ro^(-2*(1+m)))))*Bm);
                           
               SummatoryR=SummatoryR+(((((-1)^m)*Rm)/m)*(sin(2*m*Contacto))*(cos(2*m*T)));
               SummatoryT=SummatoryT+(((((-1)^m)*FIm)/m)*(sin(2*m*Contacto))*(cos(2*m*T)));
               SummatoryCort=SummatoryCort+(((((-1)^m)*Sm)/m)*(sin(2*m*Contacto))*(sin(2*m*T)));
           end
       
        SigmaR(i,j)=(Factor)*((-(((Ro^2)-(K^2))/(1-(K^2)))*((2*Contacto)/(Ro^2)))+SummatoryR);
        SigmaT(i,j)=(Factor)*((-(((Ro^2)+(K^2))/(1-(K^2)))*((2*Contacto)/(Ro^2)))+SummatoryT);
        TauRT(i,j)=(Factor)*(SummatoryCort);
        
        %Corrigiendo Valores NaN
        if isnan(SigmaR(i,j))
           SigmaR(i,j)=0; 
        end
        if isnan(SigmaT(i,j))
           SigmaT(i,j)=0;
        end
        if isnan(TauRT(i,j))
           TauRT(i,j)=0;
        end
        
        %Cálculo del Isoclínico analítico corregido
        %Isoclinico_Target(i,j)=((1/2)*atan2((2*TauRT(i,j)),(SigmaR(i,j)-SigmaT(i,j)))); %Rango entre -pi/2 y pi/2
        Isoclinico_Target(i,j)=((1/2)*atan2((((SigmaR(i,j)-SigmaT(i,j))*sin(2*T))+(2*TauRT(i,j)*cos(2*T))),(((SigmaR(i,j)-SigmaT(i,j))*cos(2*T))-(2*TauRT(i,j)*sin(2*T))))); %Rango entre -pi/2 y pi/2
        %Calcula los valores de los esfuerzos principales
        Sigma1(i,j)=((SigmaR(i,j)+SigmaT(i,j))/2)+sqrt((((SigmaR(i,j)-SigmaT(i,j))/2)^2)+(TauRT(i,j))^2);
        Sigma2(i,j)=((SigmaR(i,j)+SigmaT(i,j))/2)-sqrt((((SigmaR(i,j)-SigmaT(i,j))/2)^2)+(TauRT(i,j))^2);
        %Diferencia de esfuerzos principales
        Diferencia(i,j)=Sigma1(i,j)-Sigma2(i,j);
        
        %Transformando a coordenadas rectángulares        
        SigmaX(i,j)=((Sigma1(i,j)+Sigma2(i,j))/2)+((Sigma1(i,j)-Sigma2(i,j))/2)*cos(2*Isoclinico_Target(i,j));
        SigmaY(i,j)=((Sigma1(i,j)+Sigma2(i,j))/2)-((Sigma1(i,j)-Sigma2(i,j))/2)*cos(2*Isoclinico_Target(i,j));        
        
        else
            SigmaR(i,j)=0;
            SigmaT(i,j)=0;
            TauRT(i,j)=0;
            
            Sigma1(i,j)=0;
            Sigma2(i,j)=0;
            Isoclinico_Target(i,j)=0;
            
            Diferencia(i,j)=0;
     end
   end
end   
% ===Extracción del contorno de la figura
Bordes=edge(Plantilla>0);
Inconsistencia=(SigmaX-SigmaY)<0;
end