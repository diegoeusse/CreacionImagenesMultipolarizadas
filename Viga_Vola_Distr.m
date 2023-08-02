%====Función para generar las componentes de esfuerzos de una viga rectangular de espesor unitario en voladizo y carga distribuida transversal==========
%====Referencia: Ecuaciones de Timoshenko presentadas en (Teoria de la elasticidad, 1968).

function [Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Viga_Vola_Distr(c,l,Fuerza,Resol)

q=Fuerza; % Fuerza: Fuerza tranversal distribuida [N/m]
% c: ancho de la viga [mm]
%  l: largo de la viga [mm]
c=(c/2)*10^-3;
l=(l/2)*10^-3;

I=(2/3)*c^3; % Momento de Inercia de la sección transversal de la viga respecto al centroide

%======Plantilla
Img=zeros(Resol,Resol);%Plantilla rectangulo
%Componentes rectángulares
SigmaX=zeros(Resol,Resol);
SigmaY=zeros(Resol,Resol);
TauXY=zeros(Resol,Resol);
%Componentees principales
Sigma1=zeros(Resol,Resol);
Sigma2=zeros(Resol,Resol);
Isoclinico_Target=zeros(Resol,Resol);
%Diferencia de esfueerzos principales
Diferencia=zeros(Resol,Resol);

%==Creando plano cartersiano según imagen base
X=zeros(1,Resol);
Y=zeros(1,Resol);

 %Crea los ejes del plano, ajustando para tener origen (0,0)
if mod(Resol,2)==0 % Caso de valor de resolución asignado como par
    Paso=2*l/(Resol-2);
for i=1:Resol-1
    X(1,i)=-l+(i-1)*Paso;
    Y(1,i)=l-(i-1)*Paso;
end
 else
  Paso=2*l/(Resol-1); % Caso de valor de resolución asignado como impar
for i=1:Resol
    X(1,i)=-l+(i-1)*Paso;
    Y(1,i)=l-(i-1)*Paso;
end
end

%Creando imagen plantilla según ejes del plano cartesiano
for i=1:Resol-1 %Este ciclo evalúa la coordenada Y - filas
   for j=1:Resol-1 %Este ciclo evalúa la coordenada X - Columnas
       if Y(1,i)<=c && Y(1,i)>=-c %Condición de que esté dentro de la viga
            Img(i,j)=255;
       else
            Img(i,j)=0;
       end
   end
end

%-------------------
%=== Calculando los mapas de esfuerzos en coordenadas Rectángulares 
for i=1:Resol-1 %Este ciclo evalúa la coordenada Y - filas
   for j=1:Resol-1 %Este ciclo evalúa la coordenada X - Columnas
       if Y(1,i)<=c && Y(1,i)>=-c %Condición de que esté dentro de la viga
         SigmaX(i,j)=(q/(2*I))*(Y(i)*(l^2-X(j)^2))+(q/(2*I))*((2/3)*Y(i)^3-(2/5)*c^2*Y(i));
         SigmaY(i,j)=-(q/(2*I))*((1/3)*Y(i)^3-c^2*Y(i)+(2/3)*c^3);
         TauXY(i,j)=-(q/(2*I))*(c^2-Y(i)^2)*X(j); 
         
          %Calculando los mapas de esfuerzos principales
           Sigma1(i,j)=((SigmaX(i,j)+SigmaY(i,j))/2)+sqrt((((SigmaX(i,j)-SigmaY(i,j))/2)^2)+(TauXY(i,j))^2);
           Sigma2(i,j)=((SigmaX(i,j)+SigmaY(i,j))/2)-sqrt((((SigmaX(i,j)-SigmaY(i,j))/2)^2)+(TauXY(i,j))^2);
           Isoclinico_Target(i,j)=-(1/2)*atan2((2*TauXY(i,j)),(SigmaX(i,j)-SigmaY(i,j)));  %Calculado entre -pi/2 y pi/2
           
           %=========
           %Diferencia de esfuerzos principales en coordenadas X e Y
           Diferencia(i,j)=Sigma1(i,j)-Sigma2(i,j); %Esperado
       end
           
       end
   end
   
  % ===Extracción del contorno de la figura
Bordes=edge(Img>0);
Plantilla=Img;
Inconsistencia=(SigmaX-SigmaY)<0;   
end