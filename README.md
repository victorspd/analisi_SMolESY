# analisi_SMolESY

Aquest projecte està emmarcat en un Treball de Final de Grau d'Enginyeria Elecrònica i Automàtica de la Universitat Rovira i Virgili, en col·laboració amb Biosfer Teslab, que porta per nom "Quantificació de compostos de baix pes molecular a partir de l'espectre imaginari d'espectroscòpia 1H-RMN".

Es tracta d'un estudi de la tècnica SMolESY aplicada a un conjunt de 151 mostres de sèrum humà, amb l'objectiu de verificar la seva aplicabilitat per a la quantificació de metabòlits.
(Takis, P. G., Jiménez, B., Sands, C. J., Chekmeneva, E., & Lewis, M. R. (2020). Electronic Supplementary Information (ESI) SMolESY: An Efficient and Quantitative Alternative to On-Instrument Macromolecular 1 H-NMR Signal Suppression).

INSTRUCCIONS:

L'aplicatiu, executable en Matlab, permet fer 3 operacions:

OPCIÓ 1- Transformar els espectres Noesy a SMolESY:

  'Aquesta opció fa els següents processos:
  1- Obtenir espectre Noesy en format Matlab a partir dels arxius rmn. En cas d'error, proveu d'afegir l'arxiu "rbmnm"* a la carpeta principal.
  2- Obté la derivada de la part imaginària de l espectre (SMolESY), també en format matriu.

  *Nils Nyberg (2023) "RBNMR". MathWorks - Makers of MATLAB and Simulink - MATLAB & Simulink. https://www.mathworks.com/matlabcentral/fileexchange/40332-rbnmr (Últim accés:    24 de maig de 2023).

  Ambdós espectres s'identificaran amb autonumeració (1,2,3...) a les respectives carpetes per a poder-los redimensionar/quantificar posteriorment
  

OPCIÓ 2- Interpolar els espectres per tal d'ajustar la seva resolució

   Aquest aplicatiu està pensat per treballar amb espectres amb una resolució de 131072 punts.
   Si no és el cas dels espectres seleccionats, cal redimensionar-los. Per a fer-ho, cal disposar d'un espectre de referència amb la resolució esmentada. Aquest arxiu es      pot trobar al repositori.
   Es guardaran també amb format autonumeració a la carpeta especificada.

OPCIÓ 3- Integrar els pics per quantificar fins a 16 metabòlits

  RECORDATORI!! Assegureu-vos que l'espectre a quantificar presenta una resolució de 131072 punts. En cas contrari, redimensioneu-lo prèviament.
  Aquesta opció genera un arxiu Excel amb el nom del metabòlit i les quantificacions (àrees calculades).
  També correla les dades amb les quantificacions del CPMG, però només és vàlid per la base de dades Carratalà. Si es treballa amb una altra base de dades, ignorar aquest     resultat
