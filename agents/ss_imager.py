import argparse
import base64
import hashlib
import json
import os
import sys
from datetime import datetime
from pathlib import Path

def load_style_guide(path):
    if not path:
        return None
    with open(path, 'r') as f:
        return json.load(f)

def build_styled_prompt(prompt, style):
    if not style:
        return prompt
    palette = ', '.join(style.get('color_palette', []))
    style_desc = style.get('style_description', '')
    background = style.get('background', '')
    forbidden = ', '.join(style.get('forbidden', []))
    prefix_parts = []
    if style_desc:
        prefix_parts.append(f"Visual style: {style_desc}.")
    if palette:
        prefix_parts.append(f"Color palette: use only {palette}.")
    if background:
        prefix_parts.append(f"Background: {background}.")
    if forbidden:
        prefix_parts.append(f"Do NOT include: {forbidden}.")
    prefix = ' '.join(prefix_parts)
    return f"{prefix} {prompt}" if prefix else prompt

def compute_checksum(path):
    h = hashlib.md5()
    with open(path, 'rb') as f:
        h.update(f.read())
    return h.hexdigest()[:12]

def update_manifest(manifest_path, entry):
    data = []
    if os.path.exists(manifest_path):
        with open(manifest_path, 'r') as f:
            data = json.load(f)
    data.append(entry)
    with open(manifest_path, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"Manifest updated: {manifest_path}")

def cmd_generate(args):
    from openai import OpenAI
    client = OpenAI()
    style = load_style_guide(args.style_guide)
    styled_prompt = build_styled_prompt(args.prompt, style)
    print(f"Generating image with gpt-image-1 ({args.size}, quality={args.quality})...")
    print(f"Prompt (first 200 chars): {styled_prompt[:200]}...")
    response = client.images.generate(
        model="gpt-image-1",
        prompt=styled_prompt,
        size=args.size,
        quality=args.quality,
        n=1,
    )
    image_data = response.data[0]
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    if hasattr(image_data, 'b64_json') and image_data.b64_json:
        img_bytes = base64.b64decode(image_data.b64_json)
    elif hasattr(image_data, 'url') and image_data.url:
        import urllib.request
        with urllib.request.urlopen(image_data.url) as resp:
            img_bytes = resp.read()
    else:
        print("ERROR: No image data returned.", file=sys.stderr)
        sys.exit(1)
    with open(output_path, 'wb') as f:
        f.write(img_bytes)
    checksum = compute_checksum(output_path)
    print(f"Saved: {output_path}")
    print(f"Checksum: {checksum}")
    manifest_path = output_path.parent / '_IMAGE_MANIFEST.json'
    entry = {
        "timestamp": datetime.now().isoformat(),
        "action": "generate",
        "model": "gpt-image-1",
        "prompt": args.prompt,
        "styled_prompt": styled_prompt,
        "output": str(output_path.resolve()),
        "checksum": checksum,
        "size": args.size,
        "quality": args.quality,
    }
    update_manifest(manifest_path, entry)
    return checksum

def cmd_edit(args):
    from openai import OpenAI
    client = OpenAI()
    style = load_style_guide(args.style_guide)
    styled_prompt = build_styled_prompt(args.prompt, style)
    print(f"Editing image {args.source} with gpt-image-1...")
    print(f"Prompt (first 200 chars): {styled_prompt[:200]}...")
    with open(args.source, 'rb') as img_file:
        response = client.images.edit(
            model="gpt-image-1",
            image=img_file,
            prompt=styled_prompt,
            n=1,
        )
    image_data = response.data[0]
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    if hasattr(image_data, 'b64_json') and image_data.b64_json:
        img_bytes = base64.b64decode(image_data.b64_json)
    elif hasattr(image_data, 'url') and image_data.url:
        import urllib.request
        with urllib.request.urlopen(image_data.url) as resp:
            img_bytes = resp.read()
    else:
        print("ERROR: No image data returned.", file=sys.stderr)
        sys.exit(1)
    with open(output_path, 'wb') as f:
        f.write(img_bytes)
    checksum = compute_checksum(output_path)
    print(f"Saved: {output_path}")
    print(f"Checksum: {checksum}")
    manifest_path = output_path.parent / '_IMAGE_MANIFEST.json'
    entry = {
        "timestamp": datetime.now().isoformat(),
        "action": "edit",
        "model": "gpt-image-1",
        "source": str(Path(args.source).resolve()),
        "prompt": args.prompt,
        "styled_prompt": styled_prompt,
        "output": str(output_path.resolve()),
        "checksum": checksum,
        "size": getattr(args, 'size', '1536x1024'),
        "quality": getattr(args, 'quality', 'high'),
    }
    update_manifest(manifest_path, entry)
    return checksum

def cmd_init_style(args):
    palette = [c.strip() for c in args.palette.split(',')]
    style = {
        "project_name": args.name,
        "created": datetime.now().isoformat(),
        "color_palette": palette,
        "style_description": args.style,
        "background": "clean white",
        "recurring_elements": [],
        "forbidden": ["photorealistic humans", "watermarks", "text overlays"],
    }
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w') as f:
        json.dump(style, f, indent=2)
    print(f"Style guide saved: {output_path}")

def main():
    parser = argparse.ArgumentParser(description='SS-Imager: AI image generator for Marp slides')
    subparsers = parser.add_subparsers(dest='command')

    gen_p = subparsers.add_parser('generate')
    gen_p.add_argument('--prompt', required=True)
    gen_p.add_argument('--output', required=True)
    gen_p.add_argument('--size', default='1536x1024')
    gen_p.add_argument('--quality', default='medium')
    gen_p.add_argument('--style-guide')

    edit_p = subparsers.add_parser('edit')
    edit_p.add_argument('--source', required=True)
    edit_p.add_argument('--prompt', required=True)
    edit_p.add_argument('--output', required=True)
    edit_p.add_argument('--size', default='1536x1024')
    edit_p.add_argument('--quality', default='medium')
    edit_p.add_argument('--style-guide')

    init_p = subparsers.add_parser('init-style')
    init_p.add_argument('--name', required=True)
    init_p.add_argument('--palette', required=True)
    init_p.add_argument('--style', required=True)
    init_p.add_argument('--output', required=True)

    args = parser.parse_args()
    if args.command == 'generate':
        cmd_generate(args)
    elif args.command == 'edit':
        cmd_edit(args)
    elif args.command == 'init-style':
        cmd_init_style(args)
    else:
        parser.print_help()
        sys.exit(1)

if __name__ == '__main__':
    main()
