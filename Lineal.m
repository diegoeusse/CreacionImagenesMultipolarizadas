function [Fuerza,Name_curve]=Lineal(Frames,Carga_max)
%Generación de curva de carga, Caso: crecimiento lineal con pendiente '1'
X=0:1:Frames-1;
Y=(X/(Frames-1));
Fuerza=(Y./max2(Y))*Carga_max;
Name_curve='Lineal';
end