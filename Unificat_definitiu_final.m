% Crear la figura y establecer la posición
fig = figure('Position',[100 100 400 300]);

% Establecer el color de fondo de la figura
fig.Color = [0.9 0.9 0.9];

% Agregar un título a la figura
sgtitle('Plataforma per a la quantificació SMolEsy','FontSize',16);


btn1 = uicontrol(fig,'Style','pushbutton','String','Obtenir SMolEsy','Position',[100 200 200 50],'BackgroundColor',[0.3 0.3 0.3],'ForegroundColor',[1 1 1],'FontName','Arial','FontSize',12,'Callback',@funcion1);
btn2 = uicontrol(fig,'Style','pushbutton','String','Redimensionar','Position',[100 150 200 50],'BackgroundColor',[0.6 0.6 0.6],'ForegroundColor',[1 1 1],'FontName','Arial','FontSize',12,'Callback',@funcion2);
btn3 = uicontrol(fig,'Style','pushbutton','String','Quantificar','Position',[100 100 200 50],'BackgroundColor',[0.9 0.9 0.9],'ForegroundColor',[0.3 0.3 0.3],'FontName','Arial','FontSize',12,'Callback',@funcion3);
instr_btn1 = uicontrol(fig,'Style','pushbutton','String','Readme','Position',[300 210 60 30],'Callback',@instrucciones1);
instr_btn2 = uicontrol(fig,'Style','pushbutton','String','Readme','Position',[300 160 60 30],'Callback',@instrucciones2);
instr_btn3 = uicontrol(fig,'Style','pushbutton','String','Readme','Position',[300 110 60 30],'Callback',@instrucciones3);

function instrucciones1(hObject, eventdata, handles)
% Mostrar las instrucciones para el botón 1
msgbox({'Aquesta opció fa els següents processos:';'';'1- Obtenir espectre Noesy en format Matlab a partir dels arxius rmn. En cas d error, proveu d afegir l arxiu "rbmnm" a la carpeta principal.';'';'2- Obté la derivada de la part imaginària de l espectre (SMolEsy), també en format Matlab.';'';'Ambdós espectres s identificaran amb autonumeració (1,2,3...) a les respectives carpetes per a poder-los redimensionar/quantificar posteriorment.'});
end

function instrucciones2(hObject, eventdata, handles)
% Mostrar las instrucciones para el botón 2
msgbox({'IMPORTANT!';'';'Aquest aplicatiu està pensat per treballar amb espectres amb una resolució de 131072 punts.';'';'Si no és el cas dels espectres seleccionats, cal redimensionar-los.';'';'Per a fer-ho, cal que tinguis un espectre de referència amb la resolució esmentada. Aquest arxiu es pot trobar a la carpeta de l aplicatiu.';'';'Es guardaran també amb format autonumeració a la carpeta especificada.'});
end

function instrucciones3(hObject, eventdata, handles)
% Mostrar las instrucciones para el botón 3
msgbox({'RECORDATORI!!';'';'Assegureu-vos que l espectre a quantificar presenta una resolució de 131072 punts. En cas contrari, redimensioneu-lo prèviament.';'';'Aquesta opció genera un arxiu Excel amb el nom del metabòlit i les quantificacions (àrees calculades).';'';'També correla les dades amb les quantificacions del CPMG, però només és vàlid per la base de dades Carratalà. Si es treballa amb una altra base de dades, ignorar aquest resultat.'});
end

function funcion1(hObject, eventdata, handles)
% EXTRACCIÓ DELS ESPECTRES NOESY EN FORMAT MATRIU, PARTINT DELS ARXIUS
% OBTINGUTS DE LA RMN, I TRANSFORMACIÓ A SMOLESY

% L'usuari triarà el directori on s'hi allotgen.
% Els guardarà anomenant-los amb nombres a partir de l'1.
% L'usuari també triarà on els allotja

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

directori=uigetdir ('C:\Users\victo\Desktop\', 'Selecciona arxiu que conté els espectres Noesy')

%Nota: el primer argument de uigetdir marca el directori per defecte quan
%s'obre el quadre de diàleg. S'ha triat l'escriptori.
%El segon argument és el missatge del quadre de diàleg

% Detecció de les carpetes
files = dir(directori);             %Troba els arxius dins la carpeta
folders = files([files.isdir]);     %Tria NOMÉS les carpetes
folderNames = {folders.name};
folderNames(:,1:2)=[]               %No se per què, detecta dues carpetes inexistents


OutPath=uigetdir ('C:\Users\victo\Desktop\','A quina carpeta vols guardar els Noesy?')
OutPathTransf=uigetdir('C:\Users\victo\Desktop\','A quina carpeta vols guardar els SMolESy?')

i=0
h=waitbar((i)/length(folderNames),'Extracting NOESY spectra and transforming into SMolEsy');

for i=1:length(folderNames)
    path= strcat (directori,'\',folderNames(1,i))
    num = int2str(i)
    FinalPath= strcat(path,'\11') % Noesy es troben a la carpeta nº11
    
    FinalOutPath=strcat(OutPath,'\',num)
    FinalOutPathTransf=strcat(OutPathTransf,'\',num)
    
    matriu=rbnmr(FinalPath) %Aquí es guarda en format estructura
    
    %A partir de l'esctructura, obtenim el Noesy en format matriu
    M(1,:)=(matriu.XAxis)'
    M(2,:)=(matriu.Data)'
    save(FinalOutPath,'M')
    
    %Obtenim l'espectre transformat (guardem la part imaginària i el
    %derivem amb la funció gradient)
    clear M
    
    %P serà una matriu auxiliar
    P(1,:)=(matriu.XAxis)'
    P(2,:)=(matriu.IData)'
    
    %Ara M serà la matriu que contindrà la transformada
    M(1,:)=P(1,:)
    M(2,:)=1.11217.*gradient(P(2,:),P(1,:)); % s'hi aplica un factor d'escalat 
    
    
    save(FinalOutPathTransf,'M')
    
    clear path
    clear Finalpath
    
    waitbar((i)/(length(folderNames)));
end

close (h)
end

function funcion2(hObject, eventdata, handles)
%% Redimensionat dels espectres per tenir més resolució i adaptar-los al format
%% dels espectres d'exemple de SmolEsy Platform

%Primer s'ha de carregar la matriu que té els 131000 punts i
%anomenar-la "X", per tenir la referència de punts a interpolar

clear all

%Demanem els espectres a redimensionar (eliminem 2 arxius incorrectes)
directori=uigetdir ('C:\Users\victo\Desktop\', 'Selecciona arxiu que conté els espectres que es desitgi redimensionar')
espectres=dir(directori)
numEspectres = {espectres.name};
numEspectres(:,1:2)=[]

% Carreguem l'espectre de referència
[file,path]=uigetfile ('*.mat','Carrega espectre referència') %retorna nom d'arxiu i camí
path=strcat(path,file)          %concatenem
X= importdata(path)

savePath=uigetdir ('C:\Users\victo\Desktop\', 'Selecciona carpeta destí')



for i=1:length(numEspectres)
    n=int2str(i)
    pathFinal=strcat(directori,'\',n)
    load (pathFinal)
    
    interpolacio=interp1(M(1,:),M(2,:),X(1,:),'spline')
    
    clear M
    M(1,:)=X(1,:)
    M(2,:)=interpolacio
    
    %Per poder guardar-ho amb el mateix nom però en una carpeta diferent
    filename = strcat(n, '.mat');
    save(fullfile(savePath, filename), 'M');
end
end

function funcion3(hObject, eventdata, handles)

% QUANTIFICACIÓ DE TOTS ELS METABÒLITS
clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

metabolites={'3-hidroxibutirat','Doblet',80689,80953,80817,80841,13,80861,80889,0,0,0,0,'C8:C158';'Acetat','Singlet',77676,77742,77716,77726,12,0,0,0,0,0,0,'D8:D158';'Acetona','Singlet',76278,76390,76334,76358,13,0,0,0,0,0,0,'E8:E158';'Alanina','Doblet',79552,79688,79584,79609,13,79636,79661,0,0,0,0,'F8:F158';'Glucosa','Doblet',63157,63270,63197,63226,13,63226,63254,0,0,0,0,'I8:I158';'Glicina','Singlet',70470,70565,70517,70543,14,0,0,0,0,0,0,'M8:M158';'Histidina','Singlet',55188,55300,55237,55268,19,0,0,0,0,0,0,'N8:N158';'Lactat','Quadruplet',68012,68249,68044,68069,14,68089,68121,68141,68169,68192,68217,'O8:O158';'Treonina','Singlet',70254,70362,70294,70350,13,0,0,0,0,0,0,'Q8:Q158';'Creatinina','Singlet',68333,68421,68367,68395,15,0,0,0,0,0,0,'G8:G158';'Creatina','Especial',72764,72845,72788,72808,13,72808,72828,0,0,0,0,'H8:H158';'Tirosina','Doblet',54583,54756,54619,54652,18,54683,54708,0,0,0,0,'R8:R158';'Valina','Doblet',81453,81586,81501,81526,14,81553,81578,0,0,0,0,'S8:S158';'Isoleucina','Triplet',81886,82086,81922,81954,17,81978,82002,82034,82054,0,0,'T8:T158';'Leucina','Singlet',81846,81978,81874,81910,17,0,0,0,0,0,0,'U8:U158';'Glutamina','Singlet',75233,75494,75273,75302,13,0,0,0,0,0,0,'K8:K158'}

%Demanem els espectres a quantificar
directori=uigetdir ('C:\Users\victo\Desktop\', 'Selecciona arxiu que conté els espectres que es desitgi quantificar')
espectres=dir(directori)
numEspectres = {espectres.name};
numEspectres(:,1:2)=[]

% Menú de selecció de metabòlit que es vol quantificar
opcions = {'3-hidroxibutirat','Acetat','Acetona','Alanina','Glucosa','Glicina','Histidina','Lactat','Treonina','Creatinina','Creatina','Tirosina','Valina','Isoleucina','Leucina','Glutamina'};
opcio_seleccionada = menu('Tria el metabòlit que vols quantificar', opcions);

%Agafo nommés les dades
datos = metabolites(opcio_seleccionada, :);

nom_metab=datos{1,1}
tipus=datos{1,2}

LIM_L=datos{1,3}
LIM_R=datos{1,4}
MAX_L1=datos{1,5}
MAX_R1=datos{1,6}
MAX_C=datos{1,7}
MAX_L2=datos{1,8}
MAX_R2=datos{1,9}
MAX_L3=datos{1,10}
MAX_R3=datos{1,11}
MAX_L4=datos{1,12}
MAX_R4=datos{1,13}

ref_col_excel=datos{1,14}

i=0
h=waitbar(i/length(numEspectres),'Quantificant');


switch tipus
    %%%%%
    case {'Singlet'}
        
        for i=1:length(numEspectres)
            n=int2str(i)
            path=strcat(directori,'\',n)
            load (path)
            
            [valor,col] = max(M(2,MAX_L1:MAX_R1)) %Busca el màxim i retorna valor i columna on es troba
            
            if (col~=MAX_C)        %si no està al 18è punt de la finestra
                shift = col-MAX_C  %mirem quin és el desplaçament que cal fer
                M(2,LIM_L:LIM_R)=circshift (M(2,LIM_L:LIM_R),[0 -shift])
            end
            
            %Referenciar (sumo el punt mínim d'aquella finestra a tota la finestra)
            
            min_frame = min (M(2,MAX_L1:MAX_R1))
            
            M(2,LIM_L:LIM_R)=M(2,LIM_L:LIM_R)-min_frame
            
            %INTEGRATION
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,MAX_L1:MAX_R1)     %Valors funció
            y(1,:)=M(2,MAX_L1:MAX_R1)
            
            a(i,1)=trapz(x,y)
            
            clearvars x y
            
            
            figure (2)
            if i==1 fill([M(1,MAX_L1) M(1,MAX_R1) M(1,MAX_R1) M(1,MAX_L1)], [-0.5e5 -0.5e5 3e6 3e6], 'b', 'FaceAlpha', 0.3);
            end
            hold on
            plot (M(1,LIM_L:LIM_R),M(2,LIM_L:LIM_R))
            
            waitbar(i/length(numEspectres));
        end;
        
        
        %%%%%%%%%%%%
        
    case {'Doblet'}
        for i=1:length(numEspectres)
            n=int2str(i)
            path=strcat(directori,'\',n)
            load (path)
            
            [valor,col] = max(M(2,MAX_L1:MAX_R1)) %Busca el màxim i retorna valor i columna on es troba
            
            if (col~=MAX_C)        %si no està al 18è punt de la finestra
                shift = col-MAX_C  %mirem quin és el desplaçament que cal fer
                M(2,LIM_L:LIM_R)=circshift (M(2,LIM_L:LIM_R),[0 -shift])
            end
            
            %Referenciar (sumo el punt mínim d'aquella finestra a tota la finestra)
            
            min_1 = min (M(2,MAX_L1:MAX_R1))
            min_2 = min (M(2,MAX_L2:MAX_R2))
            min_frame = min (min_1,min_2)
            
            M(2,LIM_L:LIM_R)=M(2,LIM_L:LIM_R)-min_frame
            
            %INTEGRATION
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,MAX_L1:MAX_R1)     %Valors funció
            y(1,:)=M(2,MAX_L1:MAX_R1)
            
            a(i,1)=trapz(x,y) %Integral restant recta "base"
            
            clearvars x y
            
            % SEGONA INTEGRACIÓ (DOBLET)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,MAX_L2:MAX_R2)     %Valors funció
            y(1,:)=M(2,MAX_L2:MAX_R2)
            
            a(i,1)=a(i,1)+trapz(x,y) %Integral restant recta "base"
            
            clearvars x y
            
            figure (2)
            hold on
            plot (M(1,LIM_L:LIM_R),M(2,LIM_L:LIM_R))
            
            waitbar(i/length(numEspectres));
        end;
        
        %%%%%%%%%%%%%%%%%%%%
    case {'Triplet'}
        for i=1:length(numEspectres)
            n=int2str(i)
            path=strcat(directori,'\',n)
            load (path)
            
            [valor,col] = max(M(2,MAX_L1:MAX_R1)) %Busca el màxim i retorna valor i columna on es troba
            
            if (col~=MAX_C)        %si no està al 18è punt de la finestra
                shift = col-MAX_C  %mirem quin és el desplaçament que cal fer
                M(2,LIM_L:LIM_R)=circshift (M(2,LIM_L:LIM_R),[0 -shift])
            end
            
            %Referenciar (sumo el punt mínim d'aquella finestra a tota la finestra)
            
            
            min_frame= min (M(2,LIM_L:LIM_R))
            
            M(2,LIM_L:LIM_R)=M(2,LIM_L:LIM_R)-min_frame
            
            %INTEGRATION
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,MAX_L1:MAX_R1)     %Valors funció
            y(1,:)=M(2,MAX_L1:MAX_R1)
            
            a(i,1)=trapz(x,y) %Integral restant recta "base"
            
            clearvars x y
            
            % SEGONA INTEGRACIÓ (TRIPLET)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,MAX_L2:MAX_R2)     %Valors funció
            y(1,:)=M(2,MAX_L2:MAX_R2)
            
            a(i,1)=a(i,1)+trapz(x,y) %Integral restant recta "base"
            
            clearvars x y
            
            % TERCERA INTEGRACIÓ (TRIPLET)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,MAX_L3:MAX_R3)     %Valors funció
            y(1,:)=M(2,MAX_L3:MAX_R3)
            
            a(i,1)=a(i,1)+trapz(x,y) %Integral restant recta "base"
            
            clearvars x y
            
            figure (2)
            hold on
            plot (M(1,LIM_L:LIM_R),M(2,LIM_L:LIM_R))
            
            waitbar(i/length(numEspectres));
        end;
        
        %%%%%%%%%%%%%%%%%%%%%
    case {'Quadruplet'}
        for i=1:length(numEspectres)
            n=int2str(i)
            path=strcat(directori,'\',n)
            load (path)
            
            [valor,col] = max(M(2,MAX_L1:MAX_R1)) %Busca el màxim i retorna valor i columna on es troba
            
            if (col~=MAX_C)        %si no està al 18è punt de la finestra
                shift = col-MAX_C  %mirem quin és el desplaçament que cal fer
                M(2,LIM_L:LIM_R)=circshift (M(2,LIM_L:LIM_R),[0 -shift])
            end
            
            %Referenciar (sumo el punt mínim d'aquella finestra a tota la finestra)
            
            
            min_frame= min (M(2,LIM_L:LIM_R))
            
            M(2,LIM_L:LIM_R)=M(2,LIM_L:LIM_R)-min_frame
            
            %INTEGRATION
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,MAX_L1:MAX_R1)     %Valors funció
            y(1,:)=M(2,MAX_L1:MAX_R1)
            
            a(i,1)=trapz(x,y) %Integral restant recta "base"
            
            clearvars x y
            
            % SEGONA INTEGRACIÓ
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,MAX_L2:MAX_R2)     %Valors funció
            y(1,:)=M(2,MAX_L2:MAX_R2)
            
            a(i,1)=a(i,1)+trapz(x,y) %Integral restant recta "base"
            
            clearvars x y
            
            % TERCERA INTEGRACIÓ
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,MAX_L3:MAX_R3)     %Valors funció
            y(1,:)=M(2,MAX_L3:MAX_R3)
            
            a(i,1)=a(i,1)+trapz(x,y) %Integral restant recta "base"
            
            clearvars x y
            
            % QUARTA INTEGRACIÓ
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,MAX_L4:MAX_R4)     %Valors funció
            y(1,:)=M(2,MAX_L4:MAX_R4)
            
            a(i,1)=a(i,1)+trapz(x,y) %Integral restant recta "base"
            
            clearvars x y
            
            figure (2)
            hold on
            plot (M(1,LIM_L:LIM_R),M(2,LIM_L:LIM_R))
            
            waitbar(i/length(numEspectres));
        end;
        
        %%%%%%%%%%%%%%%%%%%%%
    case {'Especial'}
        msgbox('Aquest metabòlit és més lent de quantificar: apareixeran dues barres de progrés. Gràcies per la paciència!','Avís')
        for i=1:length(numEspectres)
            n=int2str(i)
            path=strcat(directori,'\',n)
            load (path)
            
            [valor,col] = max(M(2,68367:68395)) %Busca el màxim i retorna valor i columna on es troba
            
            if (col~=15)        %si no està al 18è punt de la finestra
                shift = col-15  %mirem quin és el desplaçament que cal fer
                
                M(2,68333:68421)=circshift (M(2,68333:68421),[0 -shift])
            end
            
            %Referenciar (sumo el punt mínim d'aquella subfinestra a tota la finestra)
            
            min_frame = min(M(2,68367:68395))
            
            M(2,68333:68421)=M(2,68333:68421)-min_frame
            
            % INTEGRATION
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,68367:68395)     %Valors funció
            y(1,:)=M(2,68367:68395)
            
            
            a(i,1)=trapz(x,y) %Integral restant recta "base"
            
%             figure (1)
%             hold on
%             plot (M(1,68333:68421),M(2,68333:68421))
%             
            waitbar(i/length(numEspectres));
        end
        
        % QUANTIFICACIÓ DE LA CREATINA
        clearvars x y
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        h=waitbar(i/length(numEspectres),'Quantificant');
        for i=1:length(numEspectres)
            n=int2str(i)
            path=strcat(directori,'\',n)
            load (path)
            
            
            %     %Càlcul de la mitjana dels laterals de la finestra per referenciar
            %     vector=[M(2,19066) M(2,19067) M(2,19068) M(2,19069) M(2,19070) M(2,19071) M(2,19089) M(2,19090) M(2,19091) M(2,19092) M(2,19093) M(2,19094)]
            %     mitja_lat=mean (vector)     %Mitjana variació respecte 0
            %
            %     M(2,:)=M(2,:)-mitja_lat     %Correcció respecte 0
            
            %%%%% Peak alignment
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [valor,col] = max(M(2,MAX_L1:MAX_R1)) %Busca el màxim i retorna valor i columna on es troba
            
            if (col~=MAX_C)        %si no està al 18è punt de la finestra
                shift = col-MAX_C %mirem quin és el desplaçament que cal fer
                
                M(2,LIM_L:LIM_R)=circshift (M(2,LIM_L:LIM_R),[0 -shift])
            end
            
            
            min_frame = min(M(2,LIM_L:LIM_R))
            
            
            M(2,LIM_L:LIM_R)=M(2,LIM_L:LIM_R)-min_frame
            
            
%             if i==462 fill([M(1,72788) M(1,72828) M(1,72828) M(1,72788)], [-0.5e5 -0.5e5 3e6 3e6], 'b', 'FaceAlpha', 0.3);
%             end
            figure(2)
            hold on
            plot (M(1,LIM_L:LIM_R),M(2,LIM_L:LIM_R))
            
            % INTEGRATION
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            x(1,:)=M(1,MAX_L1:MAX_R1)     %Valors funció
            y(1,:)=M(2,MAX_L1:MAX_R1)
            
            %     p=[M(1,18195) M(1,72808)]   %Recta "base"
            %     q=[M(2,18195) M(2,72808)]
            b(i,1)=trapz(x,y)
           
            clearvars x y 
            
            x(1,:)=M(1,MAX_L2:MAX_R2)     %Valors funció
            y(1,:)=M(2,MAX_L2:MAX_R2)
            
            b(i,1)=trapz(x,y)+b(i,1)-a(i,1)
            a(i,1)=b(i,1)
            %     figure (1)
            %     hold on
            %     plot (M(1,72764:72845),M(2,72764:72845))
            clearvars x y 
            
            waitbar(i/length(numEspectres));
        end
        
        
        
    otherwise
        error('Tipus desconegut');
end

xlswrite(nom_metab, -a); % exportar la matriz a un archivo Excel (exporto en negativo porque las áreas son negativas debido a los ejes

%Cal girar l'eix X (ppm)
ax = gca;
ax.XDir = 'reverse';

metabolite=readtable('C:\Users\victo\Desktop\URV\TFG\COVID_Carratala\Metabolomic_Results_CarratalaA.xls','Sheet','LMWM Profile','Range',ref_col_excel)
metabolite=table2array (metabolite)

%SOLUCIÓ AL PROBLEMA DE SI LA COLUMNA COMENÇA AMB ALGUN "NaN". No se per
%què,però MATLAB comença a llegir des del primer nombre

if size(metabolite,1) < length(numEspectres) % si el tamaño actual es menor al número esperado
    numNaNs = length(numEspectres) - size(metabolite,1); % calcular el número de NaNs a añadir
    metabolite = [NaN(numNaNs,1); metabolite]; % aña
end






nan_indices = isnan(metabolite); % Obtén los índices de los elementos NaN en A

a(nan_indices) = []
metabolite(nan_indices) = []



a=-a    %Canvi de signe: els eixos girats fan que les integrals siguin valors negatius

%NÚVOL DE PUNTS (la funció fitlm dibuixa tota la matriu coordenada a
%coordenada)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure
% plot (acetat(:,1),a(:,1),'.')

t=fitlm(metabolite, a)

figure
plot (t)
title (nom_metab)
end

