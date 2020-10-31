// Code récupéré de https://github.com/LAB-MI/deplacement-covid-19/blob/master/src/certificate.js
// Et adapté pour un environnement NodeJS Classique
// 
// On va récupérer les données à partir des arguments de la commande,
// Générer le QR Code à intégrer dans le PDF,
// Remplir le certificate.pdf
// Enregistrer le résultat dans data.

const PDFLib = require("pdf-lib")
var PDFDocument = PDFLib.PDFDocument;
var StandardFonts = PDFLib.StandardFonts;

const QRCode = require('qrcode')
const fs = require("fs");

const pdfBase = "certificate-confinement2.pdf"

// Récupérer les données à partir des arguments
filename=process.argv[2];
creationDate = process.argv[3];
creationHour = process.argv[4];
lastname=process.argv[5];
firstname=process.argv[6];
birthday=process.argv[7];
lieunaissance=process.argv[8];
address=process.argv[9];
zipcode=process.argv[10];
town=process.argv[11];
datesortie=process.argv[12];
releaseHours=process.argv[13];
releaseMinutes=process.argv[14];
reasons=process.argv[15];

// Construire les données
// https://github.com/LAB-MI/deplacement-covid-19/blob/master/src/certificate.js#L98
const data = [
    `Cree le: ${creationDate} a ${creationHour}`,
    `Nom: ${lastname}`,
    `Prenom: ${firstname}`,
    `Naissance: ${birthday} a ${lieunaissance}`,
    `Adresse: ${address} ${zipcode} ${town}`,
    `Sortie: ${datesortie} a ${releaseHours}h${releaseMinutes}`,
    `Motifs: ${reasons}`,
  ].join(';\n ')

const ys = {
    travail: 578,
    achats: 533,
    sante: 477,
    famille: 435,
    handicap: 396,
    sport_animaux: 358,
    convocation: 295,
    missions: 255,
    enfants: 211,
}

// Générer le QR Code à intégrer dans le PDF
// https://github.com/LAB-MI/deplacement-covid-19/blob/master/src/certificate.js#L20
const generateQR = async text => {
    try {
      var opts = {
        errorCorrectionLevel: 'M',
        type: 'image/png',
        quality: 0.92,
        margin: 1,
      }
      return await QRCode.toDataURL(text, opts)
    } catch (err) {
      console.error(err)
    }
  }  

// Générer le PDF
// https://github.com/LAB-MI/deplacement-covid-19/blob/master/src/certificate.js#L90
async function generatePdf () {
  const existingPdfBytes = fs.readFileSync(pdfBase);
  const pdfDoc = await PDFDocument.load(existingPdfBytes);

  // set pdf metadata
  pdfDoc.setTitle('COVID-19 - Déclaration de déplacement');
  pdfDoc.setSubject('Attestation de déplacement dérogatoire');
  pdfDoc.setKeywords([
    'covid19',
    'covid-19',
    'attestation',
    'déclaration',
    'déplacement',
    'officielle',
    'gouvernement',
  ]);
  pdfDoc.setProducer('DNUM/SDIT');
  pdfDoc.setCreator('');
  pdfDoc.setAuthor("Ministère de l'intérieur");

  const page1 = pdfDoc.getPages()[0];

  const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

  const drawText = (text, x, y, size = 11) => {
    page1.drawText(text, { x, y, size, font })
  }

  drawText(`${firstname} ${lastname}`, 119, 696)
  drawText(birthday, 119, 674)
  drawText(lieunaissance, 297, 674)
  drawText(`${address} ${zipcode} ${town}`, 133, 652)

  reasons
    .split(', ')
    .forEach(reason => {
      drawText('x', 78, ys[reason], 18)
  })

  drawText(town, 105, 177);

  drawText(datesortie, 91, 153, 11)
  drawText(`${releaseHours}h${releaseMinutes}`, 264, 153, 11)

  const generatedQR = await generateQR(data)

  const qrImage = await pdfDoc.embedPng(generatedQR)

  page1.drawImage(qrImage, {
    x: page1.getWidth() - 156,
    y: 100,
    width: 92,
    height: 92,
  })

  pdfDoc.addPage()
  const page2 = pdfDoc.getPages()[1]
  page2.drawImage(qrImage, {
    x: 50,
    y: page2.getHeight() - 350,
    width: 300,
    height: 300,
  })

  const pdfBytes = await pdfDoc.save()

  return pdfBytes;
}


// Ecrire le résultat de generatePdf dans $filename
generatePdf().then(res => fs.writeFile(filename, res, (err) => {
    if (err) throw err;
}) );