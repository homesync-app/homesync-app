const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

const supabaseUrl = 'https://tfavamqszdkoeabpyxms.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmYXZhbXFzemRrb2VhYnB5eG1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzMjU5MTYsImV4cCI6MjA4NjkwMTkxNn0.AifBdMFJH14E-JisRcdjWPNpjAOuj6z3J4aYYRxBCSI';
const supabase = createClient(supabaseUrl, supabaseKey);

const outputDir = 'C:\\Users\\Blas_\\Documents\\Aplicacion de Pareja\\bg_removal\\out';
const images = ['boy.png', 'girl.png', 'cat.png', 'dog.png', 'robot.png', 'bird.png'];

async function upload() {
  for (const name of images) {
    const filePath = path.join(outputDir, name);
    const fileBuffer = fs.readFileSync(filePath);
    
    console.log(`Uploading ${name}...`);
    const { data, error } = await supabase.storage
      .from('avatars')
      .upload(name, fileBuffer, {
        contentType: 'image/png',
        upsert: true
      });
      
    if (error) {
      console.error(`Error uploading ${name}:`, error.message);
    } else {
      console.log(`Successfully uploaded ${name}:`, data.path);
    }
  }
}

upload();
