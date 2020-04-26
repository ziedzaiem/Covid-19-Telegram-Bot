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

const pdfBase = "certificate.pdf"

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
  ].join('; ')

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
    const page1 = pdfDoc.getPages()[0];

    const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

    const drawText = (text, x, y, size = 11) => {
      page1.drawText(text, { x, y, size, font })
    }

    drawText(`${firstname} ${lastname}`, 123, 686)
    drawText(birthday, 123, 661)
    drawText(lieunaissance, 92, 638)
    drawText(`${address} ${zipcode} ${town}`, 134, 613)
  
    if (reasons.includes('travail')) {
        drawText('x', 76, 527, 19)
    }
    if (reasons.includes('courses')) {
        drawText('x', 76, 478, 19)
    }
    if (reasons.includes('sante')) {
        drawText('x', 76, 436, 19)
    }
    if (reasons.includes('famille')) {
        drawText('x', 76, 400, 19)
    }
    if (reasons.includes('sport')) {
        drawText('x', 76, 345, 19)
    }
    if (reasons.includes('judiciaire')) {
        drawText('x', 76, 298, 19)
    }
    if (reasons.includes('missions')) {
        drawText('x', 76, 260, 19)
    }

    drawText(town, 111, 226)
  
    if (reasons !== '') {
      // Date sortie
      drawText(datesortie, 92, 200)
      drawText(releaseHours, 200, 201)
      drawText(releaseMinutes, 220, 201)
    }

    // Date création
    drawText('Date de création:', 464, 150, 7)
    drawText(`${creationDate} à ${creationHour}`, 455, 144, 7)

    const generatedQR = await generateQR(data)

    const qrImage = await pdfDoc.embedPng(generatedQR)
  
    page1.drawImage(qrImage, {
      x: page1.getWidth() - 170,
      y: 155,
      width: 100,
      height: 100,
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