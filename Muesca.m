%=====Función para generar las componentes de esfuerzos en una placa de longitud infinita con agujero central sometida a carga de tracción==========
%====Referencia: Ecuaciones de Timoshenko presentadas en (Teoria de la elasticidad, 1968).

function [Sigma1,Sigma2,Diferencia,Isoclinico_Target,Bordes,Plantilla,Inconsistencia]=Muesca(b, d, Cf, Sapp, Resol)
eta = (5*pi())/3;
lambda = 0.512221;

% d: Es la profundidad de la muesca [m].
% h: Es el espesor de la placa [m].
% b: Es el ancho de la placa [m]  "b" debe ser mayor a la profundidad "d" de la muesca.

%Es valido precisar que esta función genera un mapa de esfuerzos en un dominio cuadrado,
%Es decir, de dimensiones l(ancho) x l(ancho)

%======Plantillas
Img=zeros(Resol,Resol);

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

%==Creando plano cartesiano según imagen base
X=zeros(1,Resol);
Y=zeros(1,Resol);

%Crea los ejes del plano, ajustando para tener origen (0,0)
if mod(Resol,2)==0 % Caso de valor de resolución asignado como par
    Paso=b/(Resol-1);
    for i=1:Resol
        X(1,i)= (-b/2)+(i-1)*Paso;
        Y(1,i)= (-b/2)+(i-1)*Paso;
    end
 else
    Paso=b/(Resol-1); % Caso de valor de resolución asignado como impar
    for i=1:Resol
        X(1,i)=-b/2+(i-1)*Paso;
        Y(1,i)=b/2-(i-1)*Paso;
    end
end

%Creando imagen plantilla según ejes del plano cartesiano
for i=1:Resol %Este ciclo evalúa la coordenada Y - filas
   for j=1:Resol %Este ciclo evalúa la coordenada X - Columnas
       if X(1,j)<0 && (Y(1,i)-(sqrt(3)/3)*X(1,j)) > 0 && (Y(1,i)+(sqrt(3)/3)*X(1,j)) < 0 %Condición para que esté en la placa y fuera de la muesca
            Img(i,j)=0;
       else
            Img(i,j)=255;
       end
   end
end

%==Creando plano polar según imagen base
r=zeros(Resol,Resol);
theta=zeros(Resol,Resol);

%==Creando plano polar según posiciones X, Y
for i=1:Resol %Este ciclo evalúa la coordenada Y - filas
   for j=1:Resol %Este ciclo evalúa la coordenada X - Columnas
       r(i,j)=(X(1,j)^2+Y(1,i)^2)^(1/2);
       theta(i,j) = atan(Y(1,i)/X(1,j));
   end
end

%-------------------
%=== Calculando los mapas de esfuerzos en Coordenadas Polares
for i=1:Resol %Este ciclo evalúa la coordenada Y - filas
        for j=1:Resol %Este ciclo evalúa la coordenada X - Columnas
           
           if X(1,j)<0 && (Y(1,i)-(sqrt(3)/3)*X(1,j)) > 0 && (Y(1,i)+(sqrt(3)/3)*X(1,j)) < 0 
               SigmaR(i,j)=0;
               SigmaT(i,j)=0;
               TauRT(i,j)=0;
           else
               SigmaR(i,j) = ((Cf*Sapp*d^(1-lambda))/(r(i,j)^(1-lambda))) * ( -lambda*(lambda+1)*cos((lambda+1)*theta(i,j)) + lambda*(lambda-3)*((cos((lambda+1)*eta/2))/(cos((lambda-1)*eta/2)))*cos((lambda-1)*theta(i,j)) );
               SigmaT(i,j) = ((Cf*Sapp*lambda*(lambda+1)*d^(1-lambda))/(r(i,j)^(1-lambda))) * ( cos((lambda+1)*theta(i,j)) - ((cos((lambda+1)*eta/2))/(cos((lambda-1)*eta/2)))*cos((lambda-1)*theta(i,j)) );
               TauRT(i,j) = ((Cf*Sapp*(lambda)*d^(1-lambda))/(r(i,j)^(1-lambda))) * ( (lambda+1)*sin((lambda+1)*theta(i,j)) - (lambda-1)*((cos((lambda+1)*eta/2))/(cos((lambda-1)*eta/2)))*sin((lambda-1)*theta(i,j)) );
           end
        
           %Calculando los mapas de esfuerzos principales
           Sigma1(i,j)=0.5*(SigmaR(i,j)+SigmaT(i,j))+sqrt((0.5*(SigmaR(i,j)-SigmaT(i,j)))^2+TauRT(i,j)^2);
           Sigma2(i,j)=0.5*(SigmaR(i,j)+SigmaT(i,j))-sqrt((0.5*(SigmaR(i,j)-SigmaT(i,j)))^2+TauRT(i,j)^2);
           Isoclinico_Target(i,j)=-(1/2)*atan2((2*TauRT(i,j)),(SigmaR(i,j)-SigmaT(i,j)));  %Calculado entre -pi/2 y pi/2

           %=========
           %Diferencia de esfuerzos principales en coordenadas X e Y
           Diferencia(i,j)=Sigma1(i,j)-Sigma2(i,j); %Esperado
           %maximo = max(max(Diferencia));
           %Diferencia = Diferencia/maximo;
        end
end

% ===Extracción del contorno de la figura
Bordes=edge(Img>0);
Plantilla=Img;
Inconsistencia=(SigmaR-SigmaT)<0;
end