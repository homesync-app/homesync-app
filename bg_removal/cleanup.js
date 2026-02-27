const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://tfavamqszdkoeabpyxms.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmYXZhbXFzemRrb2VhYnB5eG1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzMjU5MTYsImV4cCI6MjA4NjkwMTkxNn0.AifBdMFJH14E-JisRcdjWPNpjAOuj6z3J4aYYRxBCSI';
const supabase = createClient(supabaseUrl, supabaseKey);

async function cleanup() {
  console.log('Cleaning up boy_test.png...');
  const { data, error } = await supabase.storage
    .from('avatars')
    .remove(['boy_test.png']);
    
  if (error) {
    console.error('Error cleaning up:', error.message);
  } else {
    console.log('Successfully cleaned up:', data);
  }
}

cleanup();
