%=====Función para generar las componentes de esfuerzos en una ménsula curva cargada en su extremo libre ==========
%====Referencia: Ecuaciones de Timoshenko presentadas en (Teoria de la elasticidad, 1968).

function [Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Mensula(R2,R1,Fuerza,Resol)

P=(Fuerza);
N = R1^2 - R2^2 + (R1^2 + R2^2)*log(R2/R1);
A = (P/(2*N));
B = ((-P*R1^2*R2^2)/(2*N));
D = (-P/N)*(R1^2 + R2^2);

%======Plantillas
Plantilla=zeros(Resol,Resol);%Plantilla circulo
Plantilla_radio=zeros(Resol,Resol);%Plantilla circulo con radios
Plantilla_angulo=zeros(Resol,Resol);%Plantilla circulo con ángulo
%Componentes polares
SigmaR=zeros(Resol,Resol);
SigmaT=zeros(Resol,Resol);
TauRT=zeros(Resol,Resol);
%Componentees principales
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
    Paso=R2/(Resol-1);
    for i=1:Resol
        X(1,i)=(i-1)*Paso;%Coordenada X. control de columnas
        Y(1,i)=(i-1)*Paso;%Coordenada Y. control de filas
    end
else
    Paso=R2/(Resol-1); % Caso de valor de resolución asignado como impar
    for i=1:Resol
        X(1,i)=-R2+(i-1)*Paso;
        Y(1,i)=-R2+(i-1)*Paso;
    end
end

%Creando imagen plantilla a partir de valores del plano cartesiano
for i=1:Resol-1 %Este ciclo evalúa la coordenada Y - filas
   for j=1:Resol-1 %Este ciclo evalúa la coordenada X - Columnas
       if Y(1,i)^2+X(1,j)^2<=R2^2 && Y(1,i)^2+X(1,j)^2>R1^2 && Y(1,i)>=0 && X(1,j)>=0 %Condición para que sea dentro de la mensula
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
for i=1:Resol %Este ciclo evalúa la coordenada Y - filas
    for j=1:Resol %Este ciclo evalúa la coordenada X - Columnas
        if r(i,j)>R1 && r(i,j)<R2   
           SigmaR(i,j)=(2*A*r(i,j)-((2*B)/(r(i,j)^3))+(D/r(i,j)))*sin(theta(i,j));
           SigmaT(i,j)=(6*A*r(i,j)+((2*B)/(r(i,j)^3))+(D/r(i,j)))*sin(theta(i,j));
           TauRT(i,j)=-(2*A*r(i,j)-((2*B)/(r(i,j)^3))+(D/r(i,j)))*cos(theta(i,j));
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
Bordes=edge(Plantilla>0);
Inconsistencia=(SigmaR-SigmaT)<0;
end