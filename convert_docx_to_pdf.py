import os
from pathlib import Path

def convert_docx_to_pdf_method1(docx_path, output_pdf_path):
    """
    Convert DOCX to PDF using docx2pdf (requires Microsoft Word)
    """
    try:
        from docx2pdf import convert
        
        print("🔄 Attempting Windows COM (MS Word) conversion...")
        convert(docx_path, output_pdf_path)
        
        if os.path.exists(output_pdf_path):
            print("✅ Conversion successful using Microsoft Word!")
            return True
    except Exception as e:
        print(f"⚠️  MS Word method failed: {str(e)}")
        return False

def convert_docx_to_pdf_method2(docx_path, output_pdf_path):
    """
    Convert DOCX to PDF using reportlab + python-docx (pure Python)
    """
    try:
        print("🔄 Attempting Python-based DOCX to PDF conversion...")
        
        from docx import Document
        from reportlab.lib.pagesizes import letter
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import inch
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
        
        # Read DOCX
        doc = Document(docx_path)
        
        # Create PDF
        pdf_doc = SimpleDocTemplate(output_pdf_path, pagesize=letter,
                                   topMargin=1*inch, bottomMargin=1*inch,
                                   leftMargin=1*inch, rightMargin=1*inch)
        
        story = []
        styles = getSampleStyleSheet()
        
        # Custom styles using standard fonts (Helvetica instead of Calibri)
        body_style = ParagraphStyle(
            'CustomBody',
            parent=styles['Normal'],
            fontSize=11,
            fontName='Helvetica',  # Use standard font
            alignment=4,  # Justify
            leading=16,
        )
        
        heading1_style = ParagraphStyle(
            'CustomHeading1',
            parent=styles['Heading1'],
            fontSize=14,
            fontName='Helvetica-Bold',
            spaceAfter=12,
        )
        
        heading2_style = ParagraphStyle(
            'CustomHeading2',
            parent=styles['Heading2'],
            fontSize=12,
            fontName='Helvetica-Bold',
            spaceAfter=10,
        )
        
        # Process paragraphs
        for para in doc.paragraphs:
            text = para.text.strip()
            if not text:
                story.append(Spacer(1, 0.15*inch))
                continue
            
            # Basic paragraph formatting (just remove HTML-like tags if any)
            text = text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
            
            # Determine style based on paragraph style
            try:
                if para.style.name.startswith('Heading 1'):
                    story.append(Paragraph(text, heading1_style))
                elif para.style.name.startswith('Heading 2'):
                    story.append(Paragraph(text, heading2_style))
                elif para.style.name.startswith('Heading'):
                    story.append(Paragraph(text, styles['Heading3']))
                else:
                    # Regular paragraph
                    story.append(Paragraph(text, body_style))
            except:
                # Fallback for any style issues
                story.append(Paragraph(text, body_style))
            
            story.append(Spacer(1, 0.08*inch))
        
        # Build PDF
        pdf_doc.build(story)
        
        print("✅ Conversion successful using Python libraries!")
        return True
        
    except Exception as e:
        print(f"⚠️  Python method failed: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    docx_file = r"c:\Users\yugm chaudhary\Desktop\photo_exif_metadata_viewer_and_editor\APP_REPORT.docx"
    pdf_file = r"c:\Users\yugm chaudhary\Desktop\photo_exif_metadata_viewer_and_editor\APP_REPORT.pdf"
    
    print("=" * 70)
    print("DOCX to PDF Converter - Multi-Method")
    print("=" * 70)
    
    if not os.path.exists(docx_file):
        print(f"❌ DOCX file not found: {docx_file}")
        exit(1)
    
    print(f"📄 Source file: {docx_file}")
    print(f"📊 File size: {os.path.getsize(docx_file) / 1024:.2f} KB")
    print()
    
    # Try method 1: Microsoft Word (Windows COM)
    success = convert_docx_to_pdf_method1(docx_file, pdf_file)
    
    # If method 1 failed, try method 2: Python libraries
    if not success:
        print("\n🔄 Trying alternative Python-based method...")
        print("Installing required packages...")
        try:
            os.system("pip install reportlab -q")
        except:
            pass
        success = convert_docx_to_pdf_method2(docx_file, pdf_file)
    
    print()
    print("=" * 70)
    
    if success and os.path.exists(pdf_file):
        file_size = os.path.getsize(pdf_file)
        print(f"✅ Conversion Successful!")
        print(f"📊 PDF file size: {file_size / 1024:.2f} KB")
        print(f"📁 PDF location: {pdf_file}")
        print("=" * 70)
    else:
        print(f"❌ PDF conversion failed")
        print("=" * 70)
